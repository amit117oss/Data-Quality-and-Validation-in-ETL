create database Dataquality;

use Dataquality;

##Question 1: Define Data Quality. Why is it more than just data cleaning?
/*Data Quality is the measure of how fit data is for its intended purpose, judged by its accuracy, completeness, consistency, and timeliness.
Beyond Cleaning: While cleaning is the reactive process of fixing errors (like removing nulls), data quality is a proactive framework. 
It includes setting standards, continuous monitoring, and ensuring the data aligns with business logic before it even enters the system.
*/

##Question 2: Why does poor data quality lead to misleading dashboards?
/*This follows the "Garbage In, Garbage Out" (GIGO) principle. If an ETL pipeline loads duplicate sales or incorrect currency values,
 the dashboard will show inflated or deflated KPIs.
Result: Stakeholders may make expensive mistakes, such as over-investing in a failing product or missing a critical decline in customer retention,
 because the "facts" they are looking at are fundamentally wrong.
*/

##Question 3: What is duplicate data? Explain three causes in ETL.
/*Duplicate data consists of multiple records that represent the same real-world entity or event.
System Integration: Merging data from different sources (e.g., a CRM and a billing system) where the same customer exists in both.
Pipeline Retries: If an ETL job fails mid-way and is restarted without "upsert" logic, it may reload the same data again.
Manual Entry: Human error at the source, such as a salesperson entering a lead twice into the system.
*/

##Question 4: Exact vs. Partial vs. Fuzzy Duplicates
/*Exact duplicates occur when every field in two records is identical. Partial duplicates share a unique identifier (like an Email) but differ in other columns,
 such as having two different phone numbers for the same person. Fuzzy duplicates represent the same entity but have slight variations due to typos or formatting,
 such as "Jon Smith" versus "John Smith."
 */
 
 ##Question 5: Why validate during Transformation instead of after Loading?
 /*Performing validation during the Transformation phase (the "T" in ETL) is known as "shifting left."
Prevention: It prevents "polluting" the Data Warehouse with bad data.
Cost-Efficiency: It is much cheaper and faster to filter out a bad record in the pipeline than to run a massive cleanup script on a production database later.
Reliability: It ensures that by the time data is loaded, it is already "gold-standard" and ready for analysis.
*/


##Question 6: How do business rules help validate data? Give an example.
/*Business rules are logical constraints based on real-world requirements that data must follow to be considered "accurate."
How they help: They act as a filter to catch "logical" errors that a computer wouldn't otherwise recognize as "wrong."
Example: A business rule for an e-commerce site might state: "Product price cannot be less than or equal to zero.
" If the ETL encounters a product priced at -$10.00, it flags it as an error because it violates the logic of the business.
*/



CREATE TABLE Sales_Transactions (
    Txn_ID INT PRIMARY KEY,
    Customer_ID VARCHAR(10),
    Customer_Name VARCHAR(50),
    Product_ID VARCHAR(10),
    Quantity INT,
    Txn_Amount DECIMAL(10, 2),
    Txn_Date DATE,
    City VARCHAR(50)
);


INSERT INTO Sales_Transactions (Txn_ID, Customer_ID, Customer_Name, Product_ID, Quantity, Txn_Amount, Txn_Date, City)
VALUES 
(201, 'C101', 'Rahul Mehta', 'P11', 2, 4000, '2025-12-01', 'Mumbai'),
(202, 'C102', 'Anjali Rao', 'P12', 1, 1500, '2025-12-01', 'Bengaluru'),
(203, 'C101', 'Rahul Mehta', 'P11', 2, 4000, '2025-12-01', 'Mumbai'),
(204, 'C103', 'Suresh Iyer', 'P13', 3, 6000, '2025-12-02', 'Chennai'),
(205, 'C104', 'Neha Singh', 'P14', NULL, 2500, '2025-12-02', 'Delhi'),
(206, 'C105', 'N/A', 'P15', 1, NULL, '2025-12-03', 'Pune'),
(207, 'C106', 'Amit Verma', 'P16', 1, 1800, NULL, 'Pune'),
(208, 'C101', 'Rahul Mehta', 'P11', 2, 4000, '2025-12-01', 'Mumbai');


##Question 7 : Write an SQL query on Sales_Transaction to list all duplicate keys and their counts using the
##business key (Customer_ID + Product_ID + Txn_Date + Txn_Amount )

SELECT 
    Customer_ID, Product_ID, Txn_Date, Txn_Amount, 
    COUNT(*) AS Duplicate_Count
FROM 
    Sales_Transactions
GROUP BY 
    Customer_ID, Product_ID, Txn_Date, Txn_Amount
HAVING 
    COUNT(*) > 1;
    
    
   /*Question 8 : Enforcing Referential Integrity
Identify Sales_Transactions.Customer_ID values that violate referential integrity when joined with
Customers_Master and write a query to detect such violations.
*/

 CREATE TABLE Customers_Master (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customers_Master (CustomerID, CustomerName, City)
VALUES 
('C101', 'Rahul Mehta', 'Mumbai'),
('C102', 'Anjali Rao', 'Bengaluru'),
('C103', 'Suresh Iyer', 'Chennai'),
('C104', 'Neha Singh', 'Delhi');


SELECT DISTINCT 
    t.Customer_ID
FROM 
    Sales_Transactions t
LEFT JOIN 
    Customers_Master m ON t.Customer_ID = m.CustomerID
WHERE 
    m.CustomerID IS NULL;