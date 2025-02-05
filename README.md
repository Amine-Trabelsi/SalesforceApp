# 🚀 Salesforce E-Commerce Project

## 📖 Overview
This Salesforce project provides an **E-Commerce Management System** with the ability to:
- ✅ **Create Orders** from a cart.
- ✅ **Manage Products** with different categories.
- ✅ **Use Triggers to update Order totals automatically**.
- ✅ **Restrict Product creation to Managers**.
- ✅ **Provide API integration for Product Images**.

## 📂 Project Structure
### **🔹 Apex Classes**
| Class Name                 | Description |
|----------------------------|-------------|
| `OrderController`          | Manages Order creation from a cart. |
| `OrderItemTriggerHandler`  | Updates `Order__c` total price and product count on Order Item changes. |
| `ProductController`        | Manages Product creation & retrieval. |

### **🔹 Custom Objects**
| Object Name     | Description |
|----------------|-------------|
| `Order__c`     | Stores Order details with total price and product count. |
| `OrderItem__c` | Stores individual items linked to an Order. |
| `Product__c`   | Stores Product details including category, type, and price. |

---

## ⚙️ **Setup & Configuration**
### **1️⃣ Prerequisites**
- A **Salesforce Developer Org** or Sandbox.
- Installed **Salesforce CLI** (if using VS Code).
- Enabled **Custom Objects & Fields** in your Salesforce instance.

### **2️⃣ Install the Project**
#### **🔹 Using Salesforce Developer Console**
1. Go to **Setup → Developer Console**.
2. Click **File → New → Apex Class**.
3. Create the following classes:
   - `OrderController`
   - `OrderItemTriggerHandler`
   - `ProductController`
4. Copy & paste the code from the repository.

#### **🔹 Using VS Code & Salesforce CLI**
1. Clone this repository:
   ```sh
   git clone https://github.com/amine-trabelsi/salesforceApp.git
   ```
2. Deploy to Salesforce:
   ```sh
   sfdx force:source:push
   ```

---

## 🚀 **Usage**
### **1️⃣ Creating an Order**
- Orders are created when a cart is checked out.
- The `OrderItemTriggerHandler` automatically updates **total price** and **product count**.

### **2️⃣ Adding Products**
- Only **Users with `IsManager__c = true`** can create products.
- Images are **automatically fetched** from the API:
  ```
  http://www.glyffix.com/api/Image?word={PRODUCT_NAME}
  ```

### **3️⃣ Running Tests**
- **To run tests in Developer Console:**
  1. Go to **Setup → Developer Console → Test → New Run**.
  2. Select `OrderControllerTest`, `OrderItemTriggerHandlerTest`, and `ProductControllerTest`.
  3. Click **Run**.

- **To run tests via Salesforce CLI:**
  ```sh
  sfdx force:apex:test:run --resultformat human --codecoverage
  ```

---

## ✅ **Deployment Guide**
### **Using Change Sets**
1. Go to **Setup → Outbound Change Sets**.
2. Click **New Change Set** and add:
   - Apex Classes (`OrderController`, `ProductController`, `OrderItemTriggerHandler`).
   - Custom Objects (`Order__c`, `OrderItem__c`, `Product__c`).
3. Upload the change set and deploy it to your target org.

### **Using Salesforce CLI**
```sh
sfdx force:source:deploy -p force-app/main/default
```

---

## 📌 **Customization & Enhancements**
Want to add more features? Here are some ideas:
- ✅ Implement **order approval workflow** before processing.
- ✅ Add **email notifications** for order confirmations.
- ✅ Allow **discount codes** during checkout.

---

## 📜 **License**
This project is open-source under the **MIT License**.

---

## ✨ **Contributing**
Pull requests are welcome! If you find any issues or have suggestions, feel free to open an issue or PR.

---

## 📞 **Support**
- For questions, contact **aminetr76@gmail.com**.
- Check the official **Salesforce Developer Docs**: [https://developer.salesforce.com](https://developer.salesforce.com).
