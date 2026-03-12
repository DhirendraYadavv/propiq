import axios from "axios";

const API = axios.create({ baseURL: "http://3.6.88.245:8080" });

API.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

API.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem("token");
      window.location.href = "/login";
    }
    return Promise.reject(err);
  }
);

export const authAPI = {
  login: (data) => API.post("/api/auth/login", data),
  register: (data) => API.post("/api/auth/register", data),
  me: () => API.get("/api/auth/me"),
};

export const propertyAPI = {
  getAll: () => API.get("/api/properties"),
  create: (data) => API.post("/api/properties", data),
  update: (id, data) => API.put(`/api/properties/${id}`, data),
  delete: (id) => API.delete(`/api/properties/${id}`),
};

export const tenantAPI = {
  getAll: () => API.get("/api/tenants"),
  create: (data) => API.post("/api/tenants", data),
  delete: (id) => API.delete(`/api/tenants/${id}`),
};

export const leaseAPI = {
  getAll: () => API.get("/api/leases"),
  create: (data) => API.post("/api/leases", data),
};

export const rentAPI = {
  getByLease: (leaseId) => API.get(`/api/rent/lease/${leaseId}`),
  pay: (data) => API.post("/api/rent/pay", data),
};

export const propbotAPI = {
  chat: (message) =>
    axios.post("http://3.6.88.245:8000/chat", { message }),
};
