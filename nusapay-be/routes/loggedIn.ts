import express, { RequestHandler } from "express";

import {
  // addPayrollData,
  // addPayrollDetailsData,
  // loadPayrollData,
  // loadPayrollDetailsData,
  addInvoiceData,
  loadInvoiceData,
} from "../controllers/transactionController";

import {
  addOrUpdateEmployeeData,
  loadEmployeeDataFromGroup,
  addGroupName,
  addOrUpdateCompanyStats,
  addOrUpdateCompanyData,
  loadGroupName,
  deleteEmployeeDataFromGroup,
  loadCompanyTransactionHistory,
  loadDetailedEmployeeTransactionHistory,
  loadDetailedTransactionHistory
} from "../controllers/companyController";

const router = express.Router();

type RouteMethod = "get" | "post" | "put" | "delete";

type RouteDefinition = {
  method: RouteMethod;
  path: string;
  action: RequestHandler;
};

const routes: RouteDefinition[] = [
  // Payroll data

  {
    method: "post",
    path: "/loadCompanyTransactionHistory",
    action: loadCompanyTransactionHistory,
  },
  {
    method: "post",
    path: "/loadDetailedEmployeeTransactionHistory",
    action: loadDetailedEmployeeTransactionHistory,
  },
  {
    method: "post",
    path: "/loadDetailedTransactionHistory",
    action: loadDetailedTransactionHistory,
  },
  {
    method: "post",
    path: "/addInvoiceData",
    action: addInvoiceData,
  },
  
  {
    method: "post",
    path: "/loadInvoiceData",
    action: loadInvoiceData,
  },
  {
    method: "post",
    path: "/addOrUpdateEmployeeData",
    action: addOrUpdateEmployeeData,
  },

  {
    method: "post",
    path: "/deleteEmployeeDataFromGroup",
    action: deleteEmployeeDataFromGroup,
  },

  {
    method: "post",
    path: "/loadEmployeeDataFromGroup",
    action: loadEmployeeDataFromGroup,
  },

  {
    method: "post",
    path: "/addGroupName",
    action: addGroupName,
  },

  {
    method: "post",
    path: "/loadGroupName",
    action: loadGroupName,
  },

  {
    method: "post",
    path: "/addOrUpdateCompanyStats",
    action: addOrUpdateCompanyStats,
  },
  {
    method: "post",
    path: "/addOrUpdateCompanyData",
    action: addOrUpdateCompanyData,
  },
];

routes.forEach((route) => {
  router[route.method](route.path, route.action);
});

export default router;
