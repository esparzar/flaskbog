# Flask Blog

![Python](https://img.shields.io/badge/python-3.8+-blue.svg)
![Flask](https://img.shields.io/badge/flask-2.3.3-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![GitHub](https://img.shields.io/badge/gitHub-repository-brightgreen.svg)

A modern, feature-rich blog application built with Flask. Create accounts, write posts, and engage with the community.

## ✨ Features

- **User Authentication** - Register, login, and secure sessions
- **Blog Management** - Create, read, and manage posts
- **User Profiles** - Custom profiles with online status
- **Comment System** - Engage with posts through comments
- **Responsive Design** - Bootstrap-powered responsive UI
- **Real-time Status** - Online/offline user indicators

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- pip package manager

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/esparzar/flaskbog.git
   cd flaskbog
   \`\`\`

2. **Set up virtual environment**
   \`\`\`bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # venv\Scripts\activate  # Windows
   \`\`\`

3. **Install dependencies**
   \`\`\`bash
   pip install -r requirements.txt
   \`\`\`

4. **Configure environment**
   \`\`\`bash
   export FLASK_APP=run.py
   export SECRET_KEY="your-secret-key-here"
   export FLASK_ENV=development
   \`\`\`

5. **Initialize database**
   \`\`\`bash
   flask db upgrade
   \`\`\`

6. **Run the application**
   \`\`\`bash
   python run.py
   \`\`\`

7. **Visit the site**
   \`\`\`
   http://localhost:5000
   \`\`\`

## 🛠️ Technology Stack

- **Backend Framework**: Flask 2.3.3
- **Database**: SQLite with SQLAlchemy ORM
- **Authentication**: Flask-Login
- **Forms**: Flask-WTF with WTForms
- **Migrations**: Flask-Migrate with Alembic
- **Frontend**: Bootstrap 5, Jinja2 Templates

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Emmanuel Amponsah**
- GitHub: [@esparzar](https://github.com/esparzar)
