import 'dotenv/config';
import express from 'express';
import path from 'path';
import geminiRoutes from './routes';

const app = express();
const port = 3001;

app.use(express.json());
app.use(express.static(path.join(__dirname, '..', 'public')));
app.use('/', geminiRoutes);

app.listen(port, () => {
  console.log('Server listening on port ' + port);
});

