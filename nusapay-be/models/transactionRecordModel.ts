import mongoose, { Schema, Document } from "mongoose";

const TransactionRecordSchema = new Schema(
  {
    txId: {
      type: String,
      required: true,
    },
    id: {
      type: String,
      required: true,
    },
    employee: {
      type: String,
      required: true,
    },
    companyId: {
      type: String,
      required: true,
    },
    companyName : {
      type : String,
      required: true,
    },
    templateName: {
      type: String,
      required: true,
    },
    txHash: {
      type: String,
      required: true,
    },
    amountTransfer: {
      type: String,
      required: true,
    },
    API_KEY: {
      type: String,
      required: true,
      default : "2",
      // unique : true,
    },
    status: {
      type: String,
      default: "PENDING",
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
    currency: {
      type: String,
      required: true,
    },
    localCurrency: {
      type: String,
      required: true,
    },
    bankAccountName: {
      type: String,
      required: true,
    },
    bankAccount: {
      type: String,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

export const TransactionRecordModel = mongoose.model(
  "TransactionRecord",
  TransactionRecordSchema
);
