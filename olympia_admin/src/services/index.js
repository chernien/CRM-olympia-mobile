import { USE_MOCK } from '../config.js';

import authService from './authService.js';
import taskService from './taskService.js';
import demandeService from './demandeService.js';
import dashboardService from './dashboardService.js';
import clientService from './clientService.js';
import userService from './userService.js';
import objectifService from './objectifService.js';

import mockAuthService from './mock/mockAuthService.js';
import mockTaskService from './mock/mockTaskService.js';
import mockDemandeService from './mock/mockDemandeService.js';
import mockDashboardService from './mock/mockDashboardService.js';
import mockClientService from './mock/mockClientService.js';
import mockUserService from './mock/mockUserService.js';

// Each service can be real or mock independently (see USE_MOCK in config.js).
export const Services = {
  auth: USE_MOCK.auth ? mockAuthService : authService,
  tasks: USE_MOCK.tasks ? mockTaskService : taskService,
  demandes: USE_MOCK.demandes ? mockDemandeService : demandeService,
  dashboard: USE_MOCK.dashboard ? mockDashboardService : dashboardService,
  clients: USE_MOCK.clients ? mockClientService : clientService,
  users: USE_MOCK.users ? mockUserService : userService,
  objectifs: objectifService,
};
