#!/bin/bash

echo "Creating all missing templates..."

# Create directories
mkdir -p app/templates/{auth,blog,user,includes}
mkdir -p app/static/{css,js,images}

# Create blog/create.html
cat > app/templates/blog/create.html << 'EOF'
{% extends "base.html" %}

{% block title %}Create Post{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-8">
        <div class="card">
            <div class="card-header">
                <h4 class="card-title mb-0">Create New Post</h4>
            </div>
            <div class="card-body">
                <form method="POST">
                    {{ form.hidden_tag() }}
                    
                    <div class="mb-3">
                        {{ form.title.label(class="form-label") }}
                        {{ form.title(class="form-control", placeholder="Enter a compelling title for your post") }}
                        {% if form.title.errors %}
                            <div class="text-danger">
                                {% for error in form.title.errors %}
                                    <small>{{ error }}</small>
                                {% endfor %}
                            </div>
                        {% endif %}
                    </div>

                    <div class="mb-3">
                        {{ form.content.label(class="form-label") }}
                        {{ form.content(class="form-control", rows=12, placeholder="Share your thoughts, stories, or ideas...") }}
                        {% if form.content.errors %}
                            <div class="text-danger">
                                {% for error in form.content.errors %}
                                    <small>{{ error }}</small>
                                {% endfor %}
                            </div>
                        {% endif %}
                    </div>

                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                        <a href="{{ url_for('main.index') }}" class="btn btn-secondary me-md-2">Cancel</a>
                        {{ form.submit(class="btn btn-primary") }}
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF

# Create blog/post.html
cat > app/templates/blog/post.html << 'EOF'
{% extends "base.html" %}

{% block title %}{{ post.title }}{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-10">
        <article class="card">
            <div class="card-body">
                <h1 class="card-title">{{ post.title }}</h1>
                
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <small class="text-muted">
                            By 
                            <a href="{{ url_for('main.user_profile', username=post.author.username) }}">
                                {{ post.author.username }}
                            </a>
                            on {{ post.created_at.strftime('%B %d, %Y at %H:%M') }}
                        </small>
                        {% if post.updated_at != post.created_at %}
                            <small class="text-muted ms-2">
                                (Updated {{ post.updated_at.strftime('%B %d, %Y') }})
                            </small>
                        {% endif %}
                    </div>
                    
                    {% if current_user == post.author %}
                        <div>
                            <a href="#" class="btn btn-sm btn-outline-primary">Edit</a>
                            <a href="#" class="btn btn-sm btn-outline-danger">Delete</a>
                        </div>
                    {% endif %}
                </div>

                <div class="post-content">
                    {{ post.content|replace('\n', '<br>')|safe }}
                </div>
            </div>
        </article>

        <!-- Comments Section -->
        <div class="card mt-4">
            <div class="card-header">
                <h5 class="mb-0">Comments ({{ post.comments|length }})</h5>
            </div>
            <div class="card-body">
                {% if current_user.is_authenticated %}
                    <form method="POST" class="mb-4">
                        {{ form.hidden_tag() }}
                        <div class="mb-3">
                            {{ form.content.label(class="form-label") }}
                            {{ form.content(class="form-control", rows=3, placeholder="Add a comment...") }}
                            {% if form.content.errors %}
                                <div class="text-danger">
                                    {% for error in form.content.errors %}
                                        <small>{{ error }}</small>
                                    {% endfor %}
                                </div>
                            {% endif %}
                        </div>
                        {{ form.submit(class="btn btn-primary btn-sm") }}
                    </form>
                {% else %}
                    <p class="text-muted">
                        <a href="{{ url_for('auth.login') }}">Sign in</a> to leave a comment.
                    </p>
                {% endif %}

                {% if post.comments %}
                    {% for comment in post.comments %}
                        <div class="border-bottom pb-3 mb-3">
                            <div class="d-flex justify-content-between">
                                <strong>
                                    <a href="{{ url_for('main.user_profile', username=comment.author.username) }}">
                                        {{ comment.author.username }}
                                    </a>
                                </strong>
                                <small class="text-muted">{{ comment.created_at.strftime('%b %d, %Y %H:%M') }}</small>
                            </div>
                            <p class="mb-0 mt-1">{{ comment.content }}</p>
                        </div>
                    {% endfor %}
                {% else %}
                    <p class="text-muted">No comments yet. Be the first to comment!</p>
                {% endif %}
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF

# Create user/profile.html
cat > app/templates/user/profile.html << 'EOF'
{% extends "base.html" %}

{% block title %}{{ user.username }}{% endblock %}

{% block content %}
<div class="row">
    <div class="col-md-4">
        <div class="card">
            <div class="card-body text-center">
                <img src="{{ url_for('static', filename=user.avatar_url) }}" 
                     alt="{{ user.username }}" 
                     class="rounded-circle mb-3" 
                     width="150" height="150"
                     onerror="this.src='https://via.placeholder.com/150?text={{ user.username[0]|upper }}'">
                
                <div class="mb-3">
                    {% if user.online_status %}
                        <span class="badge bg-success">
                            <i class="bi bi-circle-fill"></i> Online
                        </span>
                    {% else %}
                        <span class="badge bg-secondary">
                            <i class="bi bi-circle-fill"></i> Offline
                        </span>
                        <small class="text-muted d-block mt-1">
                            Last seen: {{ user.last_seen.strftime('%Y-%m-%d %H:%M') }}
                        </small>
                    {% endif %}
                </div>
                
                <h4>{{ user.full_name or user.username }}</h4>
                <p class="text-muted">@{{ user.username }}</p>
                
                {% if current_user == user %}
                    <a href="{{ url_for('main.edit_profile') }}" class="btn btn-outline-primary btn-sm">
                        Edit Profile
                    </a>
                {% endif %}
            </div>
        </div>
    </div>
    
    <div class="col-md-8">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Profile Information</h5>
            </div>
            <div class="card-body">
                {% if user.bio %}
                    <div class="mb-3">
                        <strong>Bio:</strong>
                        <p class="mb-0">{{ user.bio }}</p>
                    </div>
                {% endif %}
                
                {% if user.location %}
                    <div class="mb-3">
                        <strong>Location:</strong>
                        <p class="mb-0">{{ user.location }}</p>
                    </div>
                {% endif %}
                
                {% if user.website %}
                    <div class="mb-3">
                        <strong>Website:</strong>
                        <a href="{{ user.website }}" target="_blank">{{ user.website }}</a>
                    </div>
                {% endif %}
                
                <div class="mb-3">
                    <strong>Member since:</strong>
                    <p class="mb-0">{{ user.created_at.strftime('%B %Y') }}</p>
                </div>
            </div>
        </div>
        
        <div class="card mt-4">
            <div class="card-header">
                <h5 class="mb-0">Recent Posts ({{ user.posts.count() }})</h5>
            </div>
            <div class="card-body">
                {% if user.posts.count() > 0 %}
                    {% for post in user.posts.limit(5).all() %}
                        <div class="mb-3 pb-3 border-bottom">
                            <h6>
                                <a href="{{ url_for('main.post_detail', post_id=post.id) }}">
                                    {{ post.title }}
                                </a>
                            </h6>
                            <small class="text-muted">{{ post.created_at.strftime('%B %d, %Y') }}</small>
                        </div>
                    {% endfor %}
                    {% if user.posts.count() > 5 %}
                        <a href="#" class="btn btn-sm btn-outline-primary">View All Posts</a>
                    {% endif %}
                {% else %}
                    <p class="text-muted">No posts yet.</p>
                {% endif %}
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF

# Create user/edit_profile.html
cat > app/templates/user/edit_profile.html << 'EOF'
{% extends "base.html" %}

{% block title %}Edit Profile{% endblock %}

{% block content %}
<div class="row justify-content-center">
    <div class="col-md-8">
        <div class="card">
            <div class="card-header">
                <h4 class="card-title mb-0">Edit Profile</h4>
            </div>
            <div class="card-body">
                <form method="POST">
                    {{ form.hidden_tag() }}
                    
                    <div class="mb-3">
                        {{ form.full_name.label(class="form-label") }}
                        {{ form.full_name(class="form-control", placeholder="Your full name") }}
                        {% if form.full_name.errors %}
                            <div class="text-danger">
                                {% for error in form.full_name.errors %}
                                    <small>{{ error }}</small>
                                {% endfor %}
                            </div>
                        {% endif %}
                    </div>

                    <div class="mb-3">
                        {{ form.bio.label(class="form-label") }}
                        {{ form.bio(class="form-control", rows=4, placeholder="Tell us about yourself...") }}
                        {% if form.bio.errors %}
                            <div class="text-danger">
                                {% for error in form.bio.errors %}
                                    <small>{{ error }}</small>
                                {% endfor %}
                            </div>
                        {% endif %}
                    </div>

                    <div class="mb-3">
                        {{ form.location.label(class="form-label") }}
                        {{ form.location(class="form-control", placeholder="Your location") }}
                        {% if form.location.errors %}
                            <div class="text-danger">
                                {% for error in form.location.errors %}
                                    <small>{{ error }}</small>
                                {% endfor %}
                            </div>
                        {% endif %}
                    </div>

                    <div class="mb-3">
                        {{ form.website.label(class="form-label") }}
                        {{ form.website(class="form-control", placeholder="https://example.com") }}
                        {% if form.website.errors %}
                            <div class="text-danger">
                                {% for error in form.website.errors %}
                                    <small>{{ error }}</small>
                                {% endfor %}
                            </div>
                        {% endif %}
                    </div>

                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                        <a href="{{ url_for('main.user_profile', username=current_user.username) }}" class="btn btn-secondary me-md-2">Cancel</a>
                        {{ form.submit(class="btn btn-primary") }}
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
{% endblock %}
EOF

# Create default avatar to fix 404 error
cat > app/static/default-avatar.png << 'EOF'
# This creates an empty file - you can replace it with an actual image later
EOF

# Create a simple favicon to fix 404 error
echo "Creating placeholder files to fix 404 errors..."

# Create empty default avatar
touch app/static/default-avatar.png

# Create basic CSS
cat > app/static/css/style.css << 'EOF'
/* Custom styles for Flask Blog */
body {
    background-color: #f8f9fa;
}

.navbar-brand {
    font-weight: bold;
}

.card {
    box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
    border: 1px solid rgba(0, 0, 0, 0.125);
}

.post-content {
    line-height: 1.6;
    font-size: 1.1rem;
}

.online-status {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    display: inline-block;
}

.online {
    background-color: #28a745;
}

.offline {
    background-color: #6c757d;
}
EOF

echo "All templates created successfully!"
echo "Listing all templates:"
find app/templates -name "*.html" | sort
echo ""
echo "Static files:"
find app/static -type f | sort