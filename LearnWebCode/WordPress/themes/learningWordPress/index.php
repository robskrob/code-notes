<?php

get_header();

<div class="site-content clearfix">

  <div class="main-column">
    if (have_posts()) :
      while (have_posts()): the_post();
        get_template_part('content', get_post_format());
      endwhile;
      else :
        echo '<p>No content found </p>';
      endif;
  </div>

  <div class="secondary-column">
    <?php dynamic_sidebar('sidebar1'); ?>
  </div>
</div>

<?php get_footer();

?>
