import numpy as np

from small_text import QueryStrategy, EmbeddingBasedQueryStrategy
from small_text.data.sampling import _get_class_histogram


def get_target_distribution_to_be_sampled(num_classes, num_samples, ignored_classes=[]):
    assert np.unique(ignored_classes).shape[0] == len(ignored_classes)
    assert np.unique(ignored_classes).shape[0] < num_classes

    num_classes_to_sample = num_classes - len(ignored_classes)
    active_classes = np.array([i for i in range(num_classes) if i not in set(ignored_classes)])

    minimum_number_of_samples_per_class = num_samples // num_classes_to_sample

    target_distribution = np.zeros((num_classes,), dtype=int)
    target_distribution[active_classes] = minimum_number_of_samples_per_class

    remainder = num_samples % num_classes_to_sample
    for _ in range(remainder):
        target_class = np.random.choice(active_classes, 1)[0]
        target_distribution[target_class] += 1

    return target_distribution


# adopted and adapted from my self-training code (original name "_rebalance")
def get_rebalanced_target_distribution(num_samples, num_classes, y, y_pred, ignored_classes=[]):
    assert y_pred.shape[0] > num_samples

    # determine how many samples are required per class to balance the class distribution
    current_class_distribution = _get_class_histogram(y, num_classes)
    predicted_class_distribution = _get_class_histogram(y_pred, num_classes)

    number_per_class_required_for_balanced_dist = current_class_distribution.max() - current_class_distribution

    number_per_class_required_for_balanced_dist[list(ignored_classes)] = 0

    target_distribution = get_target_distribution_to_be_sampled(num_classes,
                                                                num_samples,
                                                                ignored_classes=ignored_classes)

    balancing_distribution = np.zeros((num_classes,), dtype=int)
    active_classes = np.array([i for i in range(num_classes) if i not in set(ignored_classes)])

    for c in active_classes:
        if predicted_class_distribution[c] < target_distribution[c]:
            # adapt the balancing distribution so that it can be sampled
            balancing_distribution[c] = predicted_class_distribution[c]
        else:
            balancing_distribution[c] = target_distribution[c]

    remainder = target_distribution.sum() - balancing_distribution.sum()
    if remainder > 0:
        # the encountered class distribution does not have enough samples for all classes
        # try to fill the remainder with other samples from "active classes"...
        current_class_distribution += balancing_distribution

        free_active_class_samples = []
        for c in active_classes:
            class_indices = np.argwhere(y_pred == c)[:, 0]
            if class_indices.shape[0] > current_class_distribution[c]:
                free_active_class_samples.extend([c] * (class_indices.shape[0] - current_class_distribution[c]))

        np.random.shuffle(free_active_class_samples)
        for c in free_active_class_samples[:remainder]:
            balancing_distribution[c] += 1
            current_class_distribution[c] += 1

    remainder = target_distribution.sum() - balancing_distribution.sum()
    if remainder > 0:
            # if not enough samples can be taken from the active classes, we fall back to using all classes
            free_ignored_class_samples = []
            for i, count in enumerate(predicted_class_distribution - balancing_distribution):
                if count > 0:
                    free_ignored_class_samples.extend([i] * count)

            np.random.shuffle(free_ignored_class_samples)
            for c in free_ignored_class_samples[:remainder]:
                balancing_distribution[c] += 1

    return balancing_distribution


class ClassBalancer(QueryStrategy):

    def __init__(self, base_query_strategy, ignored_classes=[], subsample_size=None):
        self.base_query_strategy = base_query_strategy
        self.ignored_classes = ignored_classes
        self.subsample_size = subsample_size

    def query(self, clf, dataset, indices_unlabeled, indices_labeled, y, n=10):
        if self.subsample_size is None:
            indices = indices_unlabeled
        else:
            indices = np.random.choice(indices_unlabeled,
                                       self.subsample_size,
                                       replace=False)

        # TODO: batch this
        y_pred = clf.predict(dataset[indices])

        print(_get_class_histogram(y_pred, clf.num_classes))
        
        target_distribution = get_rebalanced_target_distribution(n,
                                                                 clf.num_classes,
                                                                 y,
                                                                 y_pred,
                                                                 ignored_classes=self.ignored_classes)
        active_classes = np.array([i for i in range(clf.num_classes)
                                   if i not in set(self.ignored_classes)])

        
        
        indices_balanced = []
        for c in active_classes:
            class_indices = np.argwhere(y_pred == c)[:, 0]
            if target_distribution[c] > 0:
                queried_indices = self.base_query_strategy.query(clf,
                                                                 dataset,
                                                                 indices_unlabeled[class_indices],
                                                                 indices_labeled,
                                                                 y,
                                                                 n=target_distribution[c])
                indices_balanced.extend(queried_indices)

        
        
        return indices[indices_balanced]


