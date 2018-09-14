# Turbolink
#thoughtbot

[Turbolinks | Speed up your Rails App | Tutorial by thoughtbot](https://thoughtbot.com/upcase/videos/turbolinks)

- finished watching

Turbolinks uses JavaScript (JS), an XHR (AJAX) request to capture every link click in your application. When one clicks on a link in your app in other words the browser does not committ to a full page refresh, which involves obtaining all the image resources and assets. 

The AJAX request that Turbolinks makes still fetches the full HTML page from the server. However Turbolinks is going to looks at the full HTML page of that response, parse out the `body` element and swap out the current body element in the DOM for the one in the response. Moreover, Turbolinks uses push state to change the url in the browser. 

What Turbolinks accomplishes with this swapping out of the Body element is it saves the browser time and memory in parsing and downloading the server's CSS and JS.

Important to note that Turbolinks has no jQuery dependency. 

### Some Drawbacks of Turbolinks:
1. Turbolinks does not fire Document Ready. Document Ready fires only once when the browser finishes loading the page from the server. If you make a Turbolinks GET to a page, Document Ready will not fire. 

*Problem*:

```javascript
$(function() {
  var menuToggle = $("#js-mobile-menu").unbind();
  $("#js-navigation-menu").removeClass("show");

  menuToggle.on("click", function(event) {
    event.preventDefault();
    $("#js-navigation-menu").slideToggle(function() {
      if($("#js-navigation-menu").is(":hidden")) {
        $("#js-navigation-menu").removeAttr("style");
      }
    });
  });
});
```


a.
As you see below, In the solution the event is still bound to `ready` but the event is also bound to `"read page:load"`. JavaScript allows the browser to hook into custom events. Turbolinks has hooked into the JavaScript system of events and now provies this `page:load` event.

```javascript
$(document).on("ready page:load", function() {
  var menuToggle = $("#js-mobile-menu").unbind();
  $("#js-navigation-menu").removeClass("show");

  menuToggle.on("click", function(event) {
    event.preventDefault();
    $("#js-navigation-menu").slideToggle(function() {
      if($("#js-navigation-menu").is(":hidden")) {
        $("#js-navigation-menu").removeAttr("style");
      }
    });
  });
});
```

b.
In `app/assets/javascript/application.js` you can pull in `//= require jquery.turbolinks`. This small plugin will fire the Turbolinks `ready page:load` event when document ready needs to fire -- like when you are transitioning through pages with Turbolinks --  so you do not have hand write `ready page:load` whenever Turbolinks runs.

2. In Turbolinks `1` there may be a progress spinner on the page when Turbolinks does a GET request. However, Turbolinks does not fire POST requests and therefore the browser displays a progress indication, which can lead to inconsistent user experience.

3. Turbolinks saves the browser from parsing everything that's in the `head` of your document -- saving the browser from having to download and parse your CSS, Javascript etc... Every time Turbolinks does a get the `head` is left untouched.

4. Do not put your `application.js` at the end of the `body`. Instead, hoist the Javascript into the `head` of the page when you are using Turbolinks because you want to take advantage of the fact that Turbolinks is only going to be loaded that one time. In short, Turbolinks MUST BE loaded from the head of the page.

5. If you are worried about loading Javascript from the `head` of the page you can flag the loading of the JS with `async: true`.

6. If you are doing any sort of tracking - google analytics for instance - in the `head`, this tracking will not fire when Turbolinks runs. For example in Google Analytics case, you can load Google analytics in the `head` but then as the first line of your `body` fire the page track event. You want to make sure you fire those page analytic events from inside the `body` so they can executed every single time Turbolinks runs. 

### Big Changes for Turbolinks 3

* Turbolinks will no longer make a full `body` swap if you want. You can opt in to only targeting different elements for updating so there's less of a DOM change on your site when Turbolinks runs.
* Github's PJAX is an alternative to Turbolinks.
