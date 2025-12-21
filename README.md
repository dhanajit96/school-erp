# Konnector School Management System

A robust, role-based School Management System built with **Ruby on Rails** and **PostgreSQL**. This application facilitates the management of multi-tenant educational organizations, handling complex relationships between Schools, Courses, Batches, and Students with strict authorization policies.

## 📋 Application Overview

The system is designed around three distinct user roles, each with scoped permissions:

1.  **Super Admin:** System-wide control. Manages Schools and School Administrators.
2.  **School Admin:** Tenant-level control. Manages Courses, Batches, Student Enrollments, and Approvals within their specific school.
3.  **Student:** End-user. Can browse courses within their school, request enrollment in batches, and track their status.

## 🛠 Tech Stack

- **Framework:** Ruby on Rails 7+
- **Database:** PostgreSQL
- **Authentication:** Devise
- **Authorization:** CanCanCan (Role-based access control)
- **Pagination:** Kaminari
- **Frontend:** Bootstrap 4 (Integrated Custom Soyuz Admin Theme)
- **Testing:** RSpec, FactoryBot, Faker

## ✨ Key Features Implemented

### User Management & Security

- **Single Table Inheritance Strategy:** Uses a single `User` model with `enum` roles (`:admin`, `:school_admin`, `:student`) for efficient querying and easier authentication management.
- **Strict Authorization:** Implemented using `CanCanCan`.
  - _School Admins_ cannot view or modify data from other schools.
  - _Students_ cannot view classmate data unless their enrollment is **approved**.
- **Secure Authentication:** Powered by Devise.

### Core Modules

- **School Management:** CRUD operations for Schools (Admin only).
- **Academic Structure:** Hierarchical management of Courses and Batches.
- **Enrollment Workflow:**
  - Students can request access to a Batch.
  - School Admins receive requests in a dedicated dashboard.
  - Approval/Denial workflow updates student access rights in real-time.
- **Search & Discovery:**
  - School Admins can search the student directory to manually add students to batches.
  - Pagination implemented across all list views for performance.

## 🚀 Setup & Installation

### Prerequisites

- Ruby 3.x
- PostgreSQL
- Bundler

### Step-by-Step Guide

1.  **Clone the repository:**

    ```bash
    git clone <repository_url>
    cd school_management_system
    ```

2.  **Install Dependencies:**

    ```bash
    bundle install
    ```

3.  **Database Setup:**
    Ensure your `config/database.yml` is configured for your local Postgres instance.

    ```bash
    rails db:create
    rails db:migrate
    ```

4.  **Seed the Database (Crucial for Demo):**
    The application includes a comprehensive seed script that generates a Super Admin, multiple Schools, School Admins, Courses, Batches, and Students with varying enrollment statuses.

    ```bash
    rails db:seed
    ```

5.  **Run the Server:**
    ```bash
    rails s
    ```
    Visit `http://localhost:3000`

---

## 🔑 Demo Credentials

After running `rails db:seed`, use the following credentials to test the different user roles:

### 1. Super Admin (Global Access)

- **Email:** `super.admin@konnector.ai`
- **Password:** `password123`
- **Capabilities:** Create Schools, Assign School Admins, View System Stats.

### 2. School Admin (Scoped Access)

- **Email:** `admin@konnector.ai`
- **Password:** `password123`
- **Capabilities:** Manage "Konnector Tech Academy". Create courses, approve student requests, search/add students.
- _Note: Attempting to access data from "Odisha State Institute" will result in Access Denied._

### 3. Student (Restricted Access)

- **Email:** `student1@konnector.ai`
- **Password:** `password123`
- **Capabilities:** View available courses, Request enrollment. Can only see "Classmates" for batches where status is `Approved`.

---

## 🧪 Testing

The application is covered by a comprehensive **RSpec** test suite, including Model tests (validations/associations), Request specs (integration/routes), and Authorization specs (Ability logic).

To run the full test suite:

```bash
bundle exec rspec
```
