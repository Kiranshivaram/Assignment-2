
import React, { useState } from 'react';
import { Container, Box, TextField, Button, Typography, List, ListItem } from '@mui/material';
import axios from 'axios';

const App = () => {
  const [query, setQuery] = useState('');
  const [chatHistory, setChatHistory] = useState([]);

  const handleSendQuery = async () => {
    if (!query.trim()) return;

    try {
      const response = await axios.post('http://localhost:8000/query', { query });
      const botResponse = response.data.response;

      setChatHistory([...chatHistory, { user: query, bot: botResponse }]);
      setQuery('');
    } catch (error) {
      console.error('Error communicating with the backend:', error);
    }
  };

  return (
    <Container maxWidth="sm" style={{ marginTop: '20px' }}>
      <Typography variant="h4" align="center" gutterBottom>
        Chatbot Interface
      </Typography>

      <Box
        style={{
          border: '1px solid #ccc',
          borderRadius: '8px',
          padding: '16px',
          height: '400px',
          overflowY: 'auto',
        }}
      >
        <List>
          {chatHistory.map((chat, index) => (
            <ListItem key={index}>
              <Typography variant="body1" style={{ fontWeight: 'bold' }}>
                User: {chat.user}
              </Typography>
              <Typography variant="body1" style={{ marginLeft: '8px' }}>
                Bot: {chat.bot}
              </Typography>
            </ListItem>
          ))}
        </List>
      </Box>

      <Box display="flex" marginTop="16px">
        <TextField
          label="Enter your query"
          variant="outlined"
          fullWidth
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        <Button
          variant="contained"
          color="primary"
          style={{ marginLeft: '8px' }}
          onClick={handleSendQuery}
        >
          Send
        </Button>
      </Box>
    </Container>
  );
};

export default App;
