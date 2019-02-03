<?php
get_header();

  <div class="site-content clearfix">
    <?php if (have_posts()) : 
      while (have_posts()) : the_post();
      
      the_content();

      endwhile;

      else :
        echo '<p> No content found </p>';
      endif; ?>

      <div class="home-columns clearfix">
        <div class="one-half">
          <?php// opinion posts loop begin here
          
          $opinionPosts = new WP_Query('cat=7&posts_per_page=2&orderby=title&order=ASC');
          
          if ($opinionPosts->have_posts()) :
            while ($opinionPosts->have_posts()) : $opinionPosts->the_post();
              <h2><?php the_title(); ?></h2>
            <?php endwhile;
            else :
              // fallback no content message here
          endif;
          wp_reset_postdata();
        </div>

        <div class="one-half last">
            // news posts loop begin here
            $newsPosts = new WP_Query('cat=6&posts_per_page=2');
            
            if ($newsPosts->have_posts()) :
              while ($newsPosts->have_posts()) : $newsPosts->the_post();
                <h2><?php the_title(); ?></h2>
              <?php endwhile;
              else :
                // fallback no content message here
            endif;
            wp_reset_postdata();
            ?>
        </div>
      </div>

  </div>

<?php get_footer() ?>
