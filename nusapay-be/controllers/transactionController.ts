import { Request, Response, response } from "express";
// import { PayrollModel, PayrollDetailModel } from "../models/payrollModel"; // Pastikan path-nya benar
import { TransactionRecordModel } from "../models/transactionRecordModel";
import axios from "axios";
import { EmployeeModel } from "../models/employeeModel";

// dari sc pas nge emitnya harus ada data data ini sehingga
// ntar mbuat invoicenya ga dari fe tapi dari listening eventnya SC

export async function addInvoiceData(req: Request, res: Response) {
  const {
    txId,
    templateName,
    employees
    // API_KEY,
    // companyId,
    // companyName,
    // currency,
    // localCurrency,
    // bankAccount,
    // bankAccountName,
    // amountTransfer
  } = req.body;
  try{
    if(employees.length === 0)
    {
      res.status(404).json({
        message: "No employee data found to create invoice",
      })
      return
    }
    else{
      employees.forEach(async (employee: any) => {
        const userData = await EmployeeModel.findOne({id : employee.employeeId});
        console.log(userData)
        if(userData != null){
          const newTx = new TransactionRecordModel({
            txId,
            id:employee.employeeId,
            employee : userData.name,
            templateName,
            txHash : crypto.randomUUID(), //sementara
            API_KEY : userData.API_KEY,
            companyId : userData.companyId,
            companyName : userData.companyName,
            currency: userData.currency,
            localCurrency: userData.localCurrency,
            bankAccount: userData.bankAccount,
            bankAccountName: userData.bankAccountName,
            amountTransfer: userData.amountTransfer,
            status: "SUCCESS", // default status
          });
        
          await newTx.save();
        }
      }
    )  
    res.status(201).json({
      message : `Success adding data for ${employees.length} employees`,
      employeesId : employees.map((emp: any) => emp.employeeId),
    })
    return
  }
}
  catch(err){
    res.status(500).json({
      message: "Error adding invoice data",
      error: err,
    });
    console.log(err)
    return;
  }
}

// async function waitUntilCompleted(
//   txHash: string,
//   API_KEY: string,
//   maxRetries = 10,
//   delayMs = 40000
// ): Promise<string> {
//   let attempt = 0;
//   while (attempt < maxRetries) {
//     const status = await loadTransactionStatusData(txHash, API_KEY);
//     if (status === "SUCCESS") return status;

//     attempt++;
//     await new Promise((resolve) => setTimeout(resolve, delayMs));
//   }
//   return "PENDING"; // or return last known status if needed
// }

export async function loadInvoiceData(req: Request, res: Response) {
  const { txId } = req.body;

  try {
    const invoice = await TransactionRecordModel.find({ txId });
    if (!invoice) {
      res.status(404).json({ message: "Invoice not found" });
      return;
    } 
    else {
      // invoice.forEach(async (i) => {
      //   console.log(i)
      //   const finalStatus = await waitUntilCompleted(
      //     i.txHash,
      //     i.API_KEY,
      //   );
      //   i.status = finalStatus;
      //   await i.save();
      //   const employeeData = await EmployeeModel.findById(i.id);
      //   const id = new mongoose.Types.ObjectId(i.id)
      //   if (!employeeData) {
      //     res.status(404).json({ message: "Can't find data for this person" });
      //     return;
      //   }
      //   else {
      //     // Convert Mongoose document ke plain object dan spread ke response
      //     const plainInvoice = i.toObject();
      //     console.log(plainInvoice)
      //   }
      // });

      res.status(200).json({
        message: "Successfully fetched invoice with updated status",
        data: invoice,
      });
      return;
    }
  } catch (err: any) {
    res.status(500).json({
      message: "Error fetching data",
      error: err.message,
    });
    return;
  }
}
// buat controller untuk ngasih akses ke FE biar bisa akses status berdasarkan txIdnya
export async function loadTransactionStatusData(
  txHash: string,
  API_KEY: string
) {
  try {
    const response = await axios.get(
      `https://idrx.co/api/transaction/user-transaction-history?transactionType=DEPOSIT_REDEEM&txHash=${txHash}&page=1&take=1`,
      {
        headers: {
          "Content-Type": "application/json",
          "idrx-api-key": API_KEY,
          "idrx-api-sig" : "v0-lo3DmbCH8U7B1HyVKW1EJ7m0IMRMwT9w-2_tZdP0"
        },
      }
    );
    if (!response.data) {
      console.log(response.data);
      return response.data;
    } else {
      console.log(response);
      console.log("[API Response]", response.data);
      console.log(response.data.records[0].status);
      return response.data.records[0].status;
    }
  } catch (err: any) {
    console.error("[Failed to call redeem-request]", err);
    // return err.message;
  }
}


