# Apex Specialist Superbadge - Salesforce Developer

This repository contains my solution to the **Apex Specialist Superbadge**, a hands-on, advanced-level project-based challenge on Salesforce Trailhead.

## 🔍 Overview

The Apex Specialist Superbadge tests the ability to develop scalable and efficient solutions in Apex by applying object-oriented programming principles and working with triggers, asynchronous processing, integration, and unit testing.

## 🧩 Key Functionality

- Writing custom **Apex classes and triggers** following best practices
- Implementing **asynchronous processes** with `@future`, `Queueable`, and `Batchable` Apex
- Performing **callouts** to external REST services and handling responses
- Creating and using **mock callouts** for testing
- Designing **unit tests** with over 75% code coverage
- Managing **bulk-safe operations** using SOQL and DML limits
- Using **custom exceptions** and error handling

## 📦 Structure

- `classes/`: Apex classes for core business logic and integrations  
- `triggers/`: Trigger files and handlers  
- `mock/`: Apex mocks for web service callouts  
- `test/`: Unit test classes for all business logic

## 🚀 About the Challenge

This project simulates work for HowWeRoll Rentals, a company that manages vehicle maintenance and equipment inventory. The challenge required:

- Automating the creation of future routine maintenance requests.
- Handling bulk operations (up to 300 records).
- Integrating with an external warehouse system via REST callouts.
- Using asynchronous and scheduled Apex.
- Writing unit tests with 100% code coverage.

All business logic was separated into handler classes following best practices.


## 📚 Trailhead Link

Learn more about the Superbadge:  
🔗 [Apex Specialist Superbadge on Trailhead](https://trailhead.salesforce.com/en/content/learn/superbadges/superbadge_apex)

---

🛠 Built with Salesforce Apex on a Trailhead Playground
