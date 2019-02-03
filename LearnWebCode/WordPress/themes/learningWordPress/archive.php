<?php
get_header();

if (have_posts()) :
  <h2><?php
  if ( is_category() ) {
    echo 'This is a category';
  } elseif ( is_tag() ) {
    echo 'Tag';
  } elseif ( is_author() ) {
    echo 'Author';
  } elseif ( is_day() ) {
    echo 'Day archive';
  } elseif ( is_month() ) {
    echo 'Month';
  } elseif ( is_year() ) {
    echo 'Year';
  } else {
    echo 'Archive:';
  }

  ?></h2>

  <?php 
  while (have_posts()): the_post();

  get_template_part('content', get_post_format());
	
	endwhile;
	else :
		echo '<p>No content found </p>';
	endif;

get_footer();

?>
