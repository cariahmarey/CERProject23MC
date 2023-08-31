import { Auth } from 'rettiwt-auth';
import { Rettiwt } from 'rettiwt-api';
import "dotenv/config.js";

async function authenticateUser() {
    try {
        const credential = await new Auth().getUserCredential({
            email: 'behrendmax8@gmail.com',
            userName: 'csgohan123',
            password: ''
        });
        
        console.log('Authentication successful');
        console.log('Cookies:', credential.cookies);
    } catch (error) {
        console.error('Authentication failed:', error.message);
    }
}

//authenticateUser();

// Access environment variables using process.env
const apiKey = process.env.API_KEY;
// Creating a new Rettiwt instance using the API_KEY
const rettiwt = new Rettiwt(apiKey);

// Example fetching user data
function fetchUserDetails(username) {
    rettiwt.user.details(username)
    .then(details => {
        console.log('User Details:');
        console.log('ID:', details.id);
        console.log('Description:', details.description);
    })
    .catch(error => {
        console.error('Error fetching user details:', error.message);
    });
}

fetchUserDetails('OlafScholz');

/**
 * Fetching the list of tweets that:
 * 	- are made by a user with username <username>,
 * 	- contain the words <word1> and <word2>
 */
rettiwt.tweet.search({
	fromUsers: ['OlafScholz'],
})
.then(data => {
    console.log('Retrieved Tweeters ID:');

    data.list.forEach(
        item => console.log(item.tweetBy)
        )
    
    // for (const tweet of data) {
    //     console.log('Tweet Text:', tweet.text);
    //     console.log('Tweeter ID:', tweet.user.id);
    //     console.log('----------------------');
    // }
})
.catch(error => {
	console.error('Error fetching tweets:', error.message);
})
