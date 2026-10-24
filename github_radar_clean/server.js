require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const axios = require('axios');

const app = express();
app.use(cors());
app.use(express.json());

// 1. API для получения трендов (с фильтрами)
app.get('/api/trending', async (req, res) => {
  // Если параметр q передан, используем его, иначе дефолтный запрос
  const query = req.query.q || 'created:>2023-09-01';
  
  try {
    const response = await axios.get(`https://api.github.com/search/repositories?q=${encodeURIComponent(query)}&sort=stars&order=desc&per_page=20`, {
      headers: { 'User-Agent': 'GitHub-Radar-App' }
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Ошибка запроса к GitHub' });
  }
});

// 2. API для поиска репозиториев по названию
app.get('/api/search', async (req, res) => {
  const query = req.query.q;
  if (!query) return res.status(400).json({ error: 'Query is required' });

  try {
    const response = await axios.get(`https://api.github.com/search/repositories?q=${encodeURIComponent(query)}&sort=stars&order=desc&per_page=20`, {
      headers: { 'User-Agent': 'GitHub-Radar-App' }
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Ошибка поиска' });
  }
});

// 3. API для получения ЛИЧНЫХ репозиториев пользователя
app.get('/api/my-repos', async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  const token = authHeader.split(' ')[1];

  try {
    const response = await axios.get('https://api.github.com/user/repos?sort=updated&per_page=20', {
      headers: { Authorization: `token ${token}` }
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch user repos' });
  }
});

// 4. Перенаправление на GitHub для авторизации (OAuth)
app.get('/api/auth/github', (req, res) => {
  const clientId = process.env.GITHUB_CLIENT_ID;
  // Жестко прописан твой адрес Codespaces
  const redirectUri = 'https://supreme-spoon-gx6vrpg6gwvq2w6p5-3000.app.github.dev/auth/callback'; 
  res.redirect(`https://github.com/login/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUri}&scope=read:user,repo`);
});

// 5. Callback от GitHub (обмен кода на токен)
app.get('/auth/callback', async (req, res) => {
  const code = req.query.code;
  if (!code) return res.status(400).send('Нет кода авторизации');

  try {
    const tokenResponse = await axios.post('https://github.com/login/oauth/access_token', {
      client_id: process.env.GITHUB_CLIENT_ID,
      client_secret: process.env.GITHUB_CLIENT_SECRET,
      code: code
    }, {
      headers: { Accept: 'application/json' }
    });

    const accessToken = tokenResponse.data.access_token;

    if (accessToken) {
      const userResponse = await axios.get('https://api.github.com/user', {
        headers: { Authorization: `token ${accessToken}` }
      });

      const user = encodeURIComponent(userResponse.data.login);
      // Передаем токен и имя обратно на фронтенд
      res.redirect(`/?token=${accessToken}&user=${user}`);
    } else {
      res.status(400).send('Ошибка получения токена');
    }
  } catch (error) {
    res.status(500).send('Ошибка сервера при авторизации');
  }
});

// Раздаем статические файлы Flutter
app.use(express.static(path.join(__dirname, 'build/web')));
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

app.listen(process.env.PORT || 3000, () => console.log(`Сервер запущен на порту ${process.env.PORT || 3000}`));