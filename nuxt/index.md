# Nuxt JS
* Organizes vue code
* Manages dependencies 
* Handles SEO
* Optimizes for speed

* A higher level framework built on top of Vue to build production level applications

## Problem 1 — Vue app from scratch is difficult
* Nuxt comes preconfigured with:
	* Vuex
	* Vue Router
	* vue-meta
	* Intelligent defaults

`npx create-nuxt-app <project-name>`


## Problem 2 — No standard folder structure
* Nuxt comes with a folder structure for: 
	* assets and components for Vue components.
	* Pages directory for views and routes

## Problem 3 — Routing configuration can get lengthy
* With nuxt you place your single file Vue components in the pages directory and nuxt automatically generates your Vue routes with zero configuration.

## Problem 4 — No standard Way to Configure

* Nuxt ships with preconfigured configuration that does not lock you in — `nuxt.config.js`
* inside `nuxt.config.js` you can override the smart defaults / pre configuration and modify any of the frameworks options.

## Problem 5 — Vue applications are not SEO friendly
* Pre Render Vue pages on the server.
* Nuxt is preconfigured to generate your application on the server along with powering up your routes to make it easy to add SEO related tags.

## Problem 6 — Vue apps on initial load can be slow.
* Nuxt application is rendered universally / statically so all the HTML, JS and CSS is ready before the browser requests it. Meaning, the HTML is prerendered, which causes your page to load faster in the browser. 
* Moreover with automatic code splitting `nuxt` is only going to load the JS needed to make your route function.

## Problem 7 — Difficult to change behavior of Framework
* Higher order module system that makes it easy to customize every aspect of `nuxt`.

__________

* Requirements:
	* [Real world Vue course](https://www.vuemastery.com/courses/real-world-vue-js/real-world-intro/)
		* [The Vue Instance - Intro to Vue.js | Vue Mastery](https://www.vuemastery.com/courses/intro-to-vue-js/vue-instance/)
	* [Vuex Mastery](https://www.vuemastery.com/courses/mastering-vuex/intro-to-vuex/)
	* [Next level Vue course](https://www.vuemastery.com/courses/next-level-vue/next-level-vue-orientation)
		* Vue CLI
		* Vue Router
		* Single file vue components
		* API calls with Axios
		* Vuex

## Creating a nuxt ap

### Layouts directory
* Contains your layouts: blog layout, store layout, home layout

### Componentes directory
* Contains reusable Vue components.

### Pages directory
* Contains our top level views (in .vue files); Used to generate routes.
* The components in our pages directory are used to generate our routes

* Nuxt ads component functionality based on which directory your component is in. 

* Layouts directory has a `default.vue` — our default layout.
* In pages directory we have an `index.vue` . This gets rendered inside the default layout
* The components directory has the `nuxt` logo. This gets rendered in the middle of the page.

So high level the structure on the HTML page is as such:
* `default.vue` layout component
	* `index.vue` page component
		* `logo.vue` reusable Vue components

### Store directory
* Your Vuex store files.

### Static directory
* Files served exactly as they are. Ex: robots.txt or favicon


### Assets folder
* this is where you put your uncompiled assets. Ex: Styles, SASS, images or fonts.

* Nuxt by default uses `vue-loader`, `file-loader` and `url-loader` for effective asset serving.
* If you place an image inside `assets` directory, this image can be called in the `pages/index.vue` component with the following html: `<img src="~/assets/logo.png">`
	* When Nuxt builds the project if the image is larger than 1 KB then the url to access the image will look like something like this: `<img src="/_nuxt/img/82f7965.png">`. The hashcode `82f7965.png` is a version half. If a new version of `logo.png` is created the version hash changes. This tells the browser to redownload the logo — otherwise if the name of the image does not change, then the update made to the logo will never appear on the browser.
	* On build if the image is less than 1 KB the `nuxt` will inline the image: `<img src="data:image/png;base64,R0l....">` . Nuxt does this to reduce inline image request.  When the image is inline the browser does not have to go fetch the image. the image is inside the HTML.

### Plugins folder
* JS plugins to load before starting the Vue app

### Middleware folder
* Custom functions to run before rendering a layout or page.

### nuxt.config.js
* We use this to modify the default `nuxt` configuration.

* We do not need a `router.js` because `nuxt` automatically generates the routes for us when we enter the page components inside the `pages` directory.
* Nuxt maps the page components to the appropriate routes.


### <nuxt /> component in layouts/default.vue 
* This is where page templates are going to get rendered.
* This is like `<router-view />` from the `vue-router` library.

* use `<nuxt-link to="/" class="brand">Real World Events</nuxt-link>` to create links to other pages.


## Universal Mode
### Single Page Application (SPA)
* In normal development, a route is requested and the server responds with an HTML page that is generated for that route: `/about-us` returns `about-us.html`.
* Whenever a route is requested (`/about-us`) from the server, the server always responds with the same `index.html` page.  The url does not matter — the same `index.html` page is responded to the client.
	* Once Vue is instantiated Vue Router will load up the `about-us` page.
	* Loading a page like this in a SPA context can actually be slow. Here’s why:
	* client makes a request to the server, server responds with `index.html` , client requests JS files, server responds with JS files, client starts up Vue and Vue shows the user the page.
	* Single page apps are not fast on initial load. They have to:
		* Download the index.html
		* Download all of the Vue application Javascript
		* Initialize the Vue app
		* Initialize Vue Router and route to the proper components
		* Do any additional API calls to fetch data to render
		* Render templates to the page
		* However once the application does all of the above and gets into the browser, the UI is going to be much faster after this initial point. 

**Universal mode**

* This is the flow of the universal mode on **initial load**:
	* client requests a page `/about-us`.
	* Instead of sending over the `index.html` , the server renders out the entire page into static HTML from Vue components, which may include API calls. 
	* The server returns to the browser the html `/about-us.html` and the user is immediately shown the `about-us.html` page. This happens before Vue is loaded.
	* At this point that the browser receives the page, the browser requests the JS files from the server, which the HTML file says the browser needs to load.
	* The server returns the JS to the page
	* Vue then gets started up on the browser, which then starts to **hydrate** the page. Hydration means Vue takes the web page which is already displayed and activates Vue which effectively makes the page behave at that point like a SPA.

* This is the flow of the universal mode **after initial load**
	* the client requests `/create` page, but the browser does not request the whole page. It only requests the JS needed to load this page. When we built our app `knux` uses `code-splitting`, which splits up all our different pages into JS files, which get loaded as needed when our user navigates to that page. This makes our application fast because we are not loading up JS that we don’t need. Not all templates, in other words, are loaded on initial load.
	* The server then responds with the JS for `/create` page to the client.
	* The client, if needed, will make an API request to the server for API data it needs.
	* Server returns API data.
	* The `create.html` page is rendered in the browser.
	* If the client then requests the `about-us.html` page which we already visited, we don’t need to get the JS for that template. If we need some data for that page, Vue will make the API requests to the server.

* After initial load and hydration our Vue application behaves like a normal SPA.
* nuxt uses code splitting to create a file for each page of the application on the server.
* Even if on the client you disable JS, the pages have already been rendered on the server. Thus, if you request pages from the server, having disabled the JS on your browser, the browser will still be able to render the page.
* If you then re-enable JS, the server rendered HTML gets displayed, JS is loaded, Vue is then instantiated, and the page is hydrated, which activates Vue on the page.

* After initial load, when Vue goes to request a new page, the client running `Vue` only requests the JS from the server needed to make that page. If we look at the response from the server that contains the JS, we see the server sends to the client the compiled template, written in JS to create virtual nodes. Vue takes this JS of virtual nodes and under the hood builds the HTML page with these nodes. 

**Smart prefetching** 

* Smart prefetching enables the browser to pre-fetch the pages depending on the visibility of their `<nuxt-link>`’s in the browser’s viewport. In other words, once the browser sees a link as `<nuxt-link>`, it makes a request to the server to load the template JS. Thus when the user goes to click on the link, the template code is already available in the browser and a trip to the server is saves when the user clicks on the link


* Universal mode increases speed of initial page load.
* Prefetching increases the speed of pages that are code-split.


## SEO with vue-meta
**Need to re watch this**

* each page should have 
	* title tag: a `<title> Event listing </title>` — this is the title used in search engine results.
	* meta tag:  `<meta name=‘description’ content=‘where you can find all the events taking place in your neighborhood’>` — this is the description used in search engine results.
 

## File based routing
* Routes are created inside `.nuxt/router.js`
* you can create nested routes by just creating a file within a folder inside pages: `/pages/event/create`. This yields: `/event/create` path.
* To create a route with a dynamic id, create a file named with an underscore within a folder: `pages/event/_id.vue`. This yields the route `/event/:id`.
* We can access the route id in our components with: `{{ this.$route.params.id }}`
* Instead of walking through all of those dots, in the export of your `script`  you can add a computed value:
```javascript
<script>
export default {
...
  computed: {
    id() {
      return this.$route.params.id
    }
  }
}
</script>
```
* To create a path of `/event` our directory should look like this. the `event/index.vue` will create and support that route:
```
- pages
  - index.vue
  - event
	  - create.vue
    - _id.vue
    - index.vue
```

* To create a dynamically named route like twitter `twitter.com/vuemastery` create a file with an underscore and name it anything: `pages/_username.vue`. Whether param id or username the parameter name can be anything.
* For child routes under a dynamic route such as `twitter.com/vuemaster/following`  create `_username` as a folder: 
```
- pages
	- _username
		- index.vue (twitter.com/vuemastery)
		- following.vue (twitter.com/vuemastery/following)
```
* `pages/_username/following.vue`
* For an error page, go inside your layouts directory and create `error.vue` — `layouts/error.vue`. You can get the error page vue template code from the nuxt documentation.

## API Calls with Axios
* The API server can be on a separate server or on the same   server that the Vue files are coming from.
* install axios with `npm install @nuxtjs/axios` and then add this NPM package to: 
```
// nuxt.config.js
module.exprts = {
  modules: ['@nuxtjs/axios']
}
```

* `asyncData` is a special hook that Vue files inside `/pages` has access to. This function `asyncData` is called each time before the page component is loaded
	* Nuxt will wait until the API call is finished to render the component
	* The object returned from this method will be merged with the component data.

## Async/Await & Progress Bar
**Rewatch**

## Using Vuex
* Create an `EventService.js` which is just an abstraction that holds all of our axios calls to the server.
* Vue actions which call `EventService.js`
* The results of the EventService will commit a mutation
* The mutation will store the  events inside the state.
* The events index page will then display events by accessing the  state.
* In our page components instead of using `asyncData` we will use the `fetch` hook.
* The `fetch` hook works both on client and server side to fill the store with data **before** rendering the page. 
* Unlike `asyncData` the `fetch` hook does not have a `return` value that merges with the component data.
* All the `fetch` needs to do is dispatch the appropriate action which populates our `Vuex` state.
* The component leverages `Vuex` state with `mapState`, which sets the component with state from the store.

### store/event.js
* State needs to return an anonymous function:
```javascript
export const state = () => ({
  events: []
})
```
If the function was not anonymous then on the server side the state would only be one instance and the state would be shared across all other requests.
* We want to create a new instance each time so that way we wrap the state in an anonymous function.
* mutation function sets the state.
* the actions, call the API service and the response then calls the commit() function with the response data to set our state with the API data
* All of the above looks like this:
```javascript
  import EventService from '@/services/EventService.js'
    export const state = () => ({
      events: []
    })
    export const mutations = {
      SET_EVENTS(state, events) {
        state.events = events
      }
    }
    export const actions = {
      fetchEvents({ commit }) {
        return EventService.getEvents().then(response => {
          commit('SET_EVENTS', response.data)
        })
      }
    }
```
* This is what a component looks like interacting with the event store:
```javascript
<script>
    import EventCard from '@/components/EventCard.vue'
    import { mapState } from 'vuex'  // <--- To map event
    export default {
      ...
      async fetch({ store, error }) {
        try {
          await store.dispatch('events/fetchEvents')
        } catch (e) {
      ...
      },
      computed: mapState({
        events: state => state.events.events
      })
    }
    </script>

```


## Universal Mode Deployment

## Static Site Generated Deployment

**Universal Deployment** — HTML is generated on every request

**Static Deployment** — HTML generated once, usually locally, and then these HTML documents are deployed to the server.