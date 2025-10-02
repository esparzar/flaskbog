from flask import Blueprint, render_template, request, current_app, flash, redirect, url_for
from flask_login import current_user, login_required
from app import db
from app.models import Post, Comment, User
from app.forms import PostForm, CommentForm, ProfileForm

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

@main.route('/create', methods=['GET', 'POST'])
@login_required
def create_post():
    form = PostForm()
    if form.validate_on_submit():
        post = Post(title=form.title.data, content=form.content.data, author=current_user)
        db.session.add(post)
        db.session.commit()
        flash('Your post has been published!', 'success')
        return redirect(url_for('main.index'))
    return render_template('blog/create.html', title='Create Post', form=form)

@main.route('/post/<int:post_id>', methods=['GET', 'POST'])
def post_detail(post_id):
    post = Post.query.get_or_404(post_id)
    form = CommentForm()
    
    if form.validate_on_submit():
        if not current_user.is_authenticated:
            flash('Please log in to comment.', 'warning')
            return redirect(url_for('auth.login'))
        
        comment = Comment(content=form.content.data, author=current_user, post=post)
        db.session.add(comment)
        db.session.commit()
        flash('Your comment has been added!', 'success')
        return redirect(url_for('main.post_detail', post_id=post.id))
    
    return render_template('blog/post.html', title=post.title, post=post, form=form)

@main.route('/user/<username>')
def user_profile(username):
    user = User.query.filter_by(username=username).first_or_404()
    return render_template('user/profile.html', user=user)

@main.route('/profile', methods=['GET', 'POST'])
@login_required
def edit_profile():
    form = ProfileForm()
    if form.validate_on_submit():
        current_user.full_name = form.full_name.data
        current_user.bio = form.bio.data
        current_user.location = form.location.data
        current_user.website = form.website.data
        db.session.commit()
        flash('Your profile has been updated!', 'success')
        return redirect(url_for('main.user_profile', username=current_user.username))
    elif request.method == 'GET':
        form.full_name.data = current_user.full_name
        form.bio.data = current_user.bio
        form.location.data = current_user.location
        form.website.data = current_user.website
    return render_template('user/edit_profile.html', title='Edit Profile', form=form)