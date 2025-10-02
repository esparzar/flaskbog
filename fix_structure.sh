#!/bin/bash

echo "Cleaning up nested directory structure..."

# Check what's in the nested templates
if [ -d "app/app/templates" ]; then
    echo "Found nested templates in app/app/templates/"
    echo "Moving content to main templates directory..."
    
    # Copy any missing templates from nested to main directory
    cp -n -r app/app/templates/* app/templates/ 2>/dev/null || true
    
    # Remove the nested directory
    rm -rf app/app
    echo "Removed nested app/app directory"
fi

# Create any missing template files in the correct location
echo "Creating missing template files..."

# Create user/profile.html if missing
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
                <h5 class="mb-0">Recent Posts</h5>
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
                {% else %}
                    <p class="text-muted">No posts yet.</p>
                {% endif %}
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
                    </div>
                </div>

                <div class="post-content">
                    {{ post.content|replace('\n', '<br>')|safe }}
                </div>
            </div>
        </article>

        <!-- Comments Section -->
        <div class="card mt-4">
            <div class="card-header">
                <h5 class="mb-0">Comments</h5>
            </div>
            <div class="card-body">
                {% if current_user.is_authenticated %}
                    <form method="POST" class="mb-4">
                        {{ form.hidden_tag() }}
                        <div class="mb-3">
                            {{ form.content.label(class="form-label") }}
                            {{ form.content(class="form-control", rows=3, placeholder="Add a comment...") }}
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
                                <strong>{{ comment.author.username }}</strong>
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
                        {{ form.full_name(class="form-control") }}
                    </div>

                    <div class="mb-3">
                        {{ form.bio.label(class="form-label") }}
                        {{ form.bio(class="form-control", rows=4) }}
                    </div>

                    <div class="mb-3">
                        {{ form.location.label(class="form-label") }}
                        {{ form.location(class="form-control") }}
                    </div>

                    <div class="mb-3">
                        {{ form.website.label(class="form-label") }}
                        {{ form.website(class="form-control") }}
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

# Remove template.sh if it exists
rm -f app/template.sh

echo "Project structure cleaned up!"
echo "All templates are now in app/templates/"
echo "Restart your application: python run.py"