#!/bin/bash

echo "Fixing circular imports..."

# Fix routes.py
cat > app/routes.py << 'EOF'
from flask import Blueprint, render_template, request, current_app, flash, redirect, url_for
from flask_login import current_user, login_required
from app import db
from app.models import Post

main = Blueprint('main', __name__)

@main.before_app_request
def before_request():
    if current_user.is_authenticated:
        current_user.ping()
        db.session.commit()

@main.route('/')
@main.route('/index')
def index():
    page = request.args.get('page', 1, type=int)
    posts = Post.query.order_by(Post.created_at.desc()).paginate(
        page=page, per_page=current_app.config['POSTS_PER_PAGE'], error_out=False)
    return render_template('index.html', title='Home', posts=posts)

@main.route('/about')
def about():
    return render_template('about.html', title='About')
EOF

# Fix auth.py
cat > app/auth.py << 'EOF'
from flask import Blueprint, render_template

auth = Blueprint('auth', __name__)

@auth.route('/login')
def login():
    return render_template('auth/login.html', title='Login')

@auth.route('/register')
def register():
    return render_template('auth/register.html', title='Register')
EOF

# Create basic templates
mkdir -p app/templates/auth
mkdir -p app/templates/blog
mkdir -p app/templates/user

# Create basic index template
cat > app/templates/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }} - Flask Blog</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{{ url_for('main.index') }}">Flask Blog</a>
        </div>
    </nav>
    
    <div class="container mt-4">
        <h1>Welcome to Flask Blog!</h1>
        <p>Your blog application is running successfully.</p>
        
        <div class="row">
            <div class="col-md-8">
                <h2>Recent Posts</h2>
                {% if posts.items %}
                    {% for post in posts.items %}
                        <div class="card mb-3">
                            <div class="card-body">
                                <h5 class="card-title">{{ post.title }}</h5>
                                <p class="card-text">{{ post.content[:200] }}...</p>
                                <small class="text-muted">By {{ post.author.username }} on {{ post.created_at.strftime('%Y-%m-%d') }}</small>
                            </div>
                        </div>
                    {% endfor %}
                {% else %}
                    <p>No posts yet. <a href="{{ url_for('auth.register') }}">Register</a> and create the first post!</p>
                {% endif %}
            </div>
            <div class="col-md-4">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Quick Links</h5>
                        <a href="{{ url_for('auth.login') }}" class="btn btn-primary btn-sm">Login</a>
                        <a href="{{ url_for('auth.register') }}" class="btn btn-outline-primary btn-sm">Register</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Create login template
cat > app/templates/auth/login.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }} - Flask Blog</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body">
                        <h2 class="card-title text-center">Login</h2>
                        <p class="text-center">Login functionality will be implemented soon.</p>
                        <div class="text-center">
                            <a href="{{ url_for('main.index') }}" class="btn btn-primary">Back to Home</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Create register template
cat > app/templates/auth/register.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }} - Flask Blog</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body">
                        <h2 class="card-title text-center">Register</h2>
                        <p class="text-center">Registration functionality will be implemented soon.</p>
                        <div class="text-center">
                            <a href="{{ url_for('main.index') }}" class="btn btn-primary">Back to Home</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

echo "Fixed! Now run these commands:"
echo "export FLASK_APP=run.py"
echo "flask db init"
echo "flask db migrate -m 'Initial migration'"
echo "flask db upgrade"
echo "python run.py"