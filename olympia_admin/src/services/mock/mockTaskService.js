import { MOCK_TASKS } from '../../data/mockData.js';

// In-memory task store — mutated by create/update/delete
let _tasks = MOCK_TASKS.map((t) => ({ ...t }));

const mockTaskService = {
  async getTasks({ page = 1, pageSize = 20, statut } = {}) {
    await _delay(400);
    let list = statut ? _tasks.filter((t) => t.statut === statut) : [..._tasks];
    const total = list.length;
    const start = (page - 1) * pageSize;
    list = list.slice(start, start + pageSize);
    return { data: { data: list, total, page, pageSize }, error: null };
  },

  async getTaskById(id) {
    await _delay(200);
    const task = _tasks.find((t) => t.id === id);
    if (!task) return { data: null, error: { message: 'Tâche introuvable', code: 404 } };
    return { data: task, error: null };
  },

  async createTask(task) {
    await _delay(500);
    const newTask = {
      ...task,
      id: `tsk-${String(_tasks.length + 1).padStart(3, '0')}`,
      numero: `T-2026-${String(_tasks.length + 1).padStart(4, '0')}`,
      statut: 'en_cours_traitement',
      createdAt: new Date().toISOString().slice(0, 10),
    };
    _tasks = [newTask, ..._tasks];
    return { data: newTask, error: null };
  },

  async updateTaskStatus(id, statut) {
    await _delay(400);
    const idx = _tasks.findIndex((t) => t.id === id);
    if (idx === -1) return { data: null, error: { message: 'Tâche introuvable', code: 404 } };
    _tasks[idx] = { ..._tasks[idx], statut };
    return { data: _tasks[idx], error: null };
  },

  async updateTask(id, patch) {
    await _delay(400);
    const idx = _tasks.findIndex((t) => t.id === id);
    if (idx === -1) return { data: null, error: { message: 'Tâche introuvable', code: 404 } };
    _tasks[idx] = { ..._tasks[idx], ...patch };
    return { data: _tasks[idx], error: null };
  },

  async deleteTask(id) {
    await _delay(300);
    const idx = _tasks.findIndex((t) => t.id === id);
    if (idx === -1) return { data: null, error: { message: 'Tâche introuvable', code: 404 } };
    _tasks = _tasks.filter((t) => t.id !== id);
    return { data: null, error: null };
  },
};

function _delay(ms) { return new Promise((r) => setTimeout(r, ms)); }

export default mockTaskService;
