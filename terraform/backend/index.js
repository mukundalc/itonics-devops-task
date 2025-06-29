const { Client } = require('pg');

const dbConfig = {
  host: process.env.PG_HOST,
  port: parseInt(process.env.PG_PORT || '5432'),
  user: process.env.PG_USER,
  password: process.env.PG_PASSWORD,
  database: process.env.PG_DATABASE,
  ssl: {
    rejectUnauthorized: false // use true + CA for production
  }
};

const DEBUG = process.env.DEBUG ? process.env.DEBUG.toLowerCase() === 'true' : false;

exports.handler = async (event) => {
    let messageId;

    if (DEBUG) {
      console.log('event is', JSON.stringify(event, null, 2));
    }

    messageId = event.pathParameters?.messageId;

    if (DEBUG) {
      console.log('messageId', messageId);
    }

    if (!messageId) {
      console.error('No messageId in the event.\nMake sure the Integration Request has a Mapping Template that creates a JSON in this format\n{\n  "messageId": "<messageId>"\n}');
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Missing id parameter' }),
      };
    }

    if (DEBUG) {
      console.log('Getting DB client...');
    }
    const client = new Client(dbConfig);

    try {
      if (DEBUG) {
        console.log('Opening DB connection...')
      }
      await client.connect();

      const query = 'SELECT * FROM messages WHERE message_id = $1';

      if (DEBUG) {
        console.log('Running query...');
      }
      const result = await client.query(query, [messageId]);
      if (DEBUG) {
        console.log('Got result!');
      }
      if (result.rows.length === 0) {
        return {
          statusCode: 404,
          body: JSON.stringify({ error: 'Message not found' }),
        };
      }

      return {
        statusCode: 200,
        body: JSON.stringify(result.rows[0]),
      };
    } catch (error) {
      console.error(error);
      return {        
        statusCode: 500,
        body: JSON.stringify({ error: 'Database error', details: error.message }),
      };
    } finally {
      await client.end();
  }
};
