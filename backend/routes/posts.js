var express = require('express');
var router = express.Router();
const Post = require('../models/post');


router.get('/', async (req, res) => {
  try {
    const posts = await Post.findAll();
    res.status(200).json({ data: posts }); 
  } catch (error) {
    console.error('Error retrieving posts:', error);
    res.status(500).json({ error: 'Error retrieving posts' });
  }
});

router.post('/', async (req, res) => {
  const { title, description } = req.body;
  try {
    const newPost = await Post.create({ title, description });
    res.status(201).json(newPost); 
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(400).json({ error: 'Error creating post' });
  }
});


router.get('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const post = await Post.findByPk(id);
    if (post) {
      res.status(200).json(post); 
    } else {
      res.status(404).json({ error: 'Post not found' });
    }
  } catch (error) {
    console.error('Error retrieving post:', error);
    res.status(500).json({ error: 'Error retrieving post' });
  }
});

router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { title, description } = req.body;
  try {
    const post = await Post.findByPk(id);
    if (post) {
      post.title = title || post.title; 
      post.description = description || post.description;
      await post.save(); 
      res.status(200).json(post); 
    } else {
      res.status(404).json({ error: 'Post not found' });
    }
  } catch (error) {
    console.error('Error updating post:', error);
    res.status(500).json({ error: 'Error updating post' });
  }
});

router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const post = await Post.findByPk(id);
    if (post) {
      await post.destroy(); 
      res.status(200).json({ message: 'Post deleted successfully' });
    } else {
      res.status(404).json({ error: 'Post not found' });
    }
  } catch (error) {
    console.error('Error deleting post:', error);
    res.status(500).json({ error: 'Error deleting post' });
  }
});

module.exports = router;
