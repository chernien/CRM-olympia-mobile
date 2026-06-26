import { MOCK_DASHBOARD } from '../../data/mockData.js';

const mockDashboardService = {
  async getStats(periode = 'month') {
    await _delay(300);
    const d = MOCK_DASHBOARD[periode] ?? MOCK_DASHBOARD.month;
    return { data: d, error: null };
  },

  async getCA(periode = 'month') {
    await _delay(300);
    const d = MOCK_DASHBOARD[periode] ?? MOCK_DASHBOARD.month;
    return {
      data: {
        total: d.ca, intern: d.caIntern, extern: d.caExtern, olybat: d.caOlybat,
        points: d.caPoints,
      },
      error: null,
    };
  },
};

function _delay(ms) { return new Promise((r) => setTimeout(r, ms)); }

export default mockDashboardService;
