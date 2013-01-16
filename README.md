# weebo

Define Google Analytics Content Experiments with ease.

Why the name? It's the little robot from the Walt Disney movie [Flubber](http://en.wikipedia.org/wiki/Flubber_\(film\)).

## Usage

Setting up experiments consists of two steps:

1. Create an experiment in Google Analytics
2. Add the experiment in your application
3. Add variations as views/partials

### Example: Experiment for a product details page

Let's say you want to experiment with your product details page which is available as http://yourdomain.com/products/a-product-slug and has its code placed in your Rails application under `app/views/products/show.html.erb`.

1. Create an experiment in Google Analytics with the desired name (e.g. "Product Details")
2. Google Analytics asks you for the URLs for the original and variation pages. Enter "yourdomain.com/products" as the original URL and "?gace_var=var_1" for the first variation's URL. Don't worry about the warning that the previews aren't shown correctly.
3. Google Analytics gives you a JavaScript snippet. You only need the experiment key (e.g. 13371337-1).
4. Add a file `app/experiments/product_details.rb` with the following code:

``` ruby
Weebo.experiment :path => /^\/products\/[\w-]+/, :name => 'product_details', :code => '13371337-1'
```

5. Create a file `app/experiments/product_details/var_1/products/show.html.erb` with the appropriate code (e.g. copy and paste the original view's code and change the things you want changed for your experiment).

### Experiment settings

Every experiment has the following mandatory settings:

- `:path`: a regex (recommended) or string that matches the original page. Example: `/^\/products\/[\w-]+/` matches `/products/a-product-slug`.
- `:name`: the name of the experiment. This is used to look up the variations on the file system and is also used as a URL parameter so use only characters that can be used in the file system and URLs. Example: `product_details` will add a URL parameter `gace_exp=product_details` and will look for variations in `app/experiments/product_details`.
- `:code`: the code of the experiment, generated by Google Analytics. Note that this is *not* your Google Analytics tracking code. Example: 13371337-1.

## Under the hood

### Design goals

weebo was developed with the following goals in mind:

- The developer(s) should be able to set up Google Analytics Content Experiments with almost zero effort.
- The developer(s) should not clutter the original views with experiment-related code.
- Use Rails default mechanisms where possible instead of scary (and brittle) hacks.

### How variations are triggered

weebo takes a few steps to make adding experiments painless:

- weebo uses the [routing-filter gem](https://github.com/svenfuchs/routing-filter) to hook into Rails' routing and detect whether or not an experiment has been set up for the current URL (based on the `:path` setting). If it finds a matching experiment, it sets the `gace_exp` parameter to the experiment name (e.g. `gace_exp=product_details`).
- weebo then checks if a variation has been requested by looking at the `gace_exp` parameter. If the parameter has been set, it prepends the given variation's path to the controller's view path so they get rendered instead of the original.
- If weebo finds an experiment for the current URL but no (valid) variation has been requested, it injects a JavaScript snippet at the beginning of the response's `<head>` section to trigger Google Analytics' experiment handler.
- When the original page is rendered, the JavaScript snippet may or may not trigger a client-side JavaScript-based redirect to variation page – this decision is actually up to Google Analytics.

## Advanced usage

### Replacing partials

Replacing partials works just like replacing whole views: Put the partial containing your change(s) in the same path as your original.

Example:
``` erb
# in app/views/products/show.html.erb we render the partial app/views/products/_properties.html.erb:
<%= render 'properties', :product => @product %>
```
To experiment with the `properties` partial, add an experiment (e.g. named `product_properties`) and create your changed partial in `app/experiments/product_properties/products/_properties.html.erb`.

## TODO

- Add tests :)
- Maybe implement as Rack middleware rather than before/after filters?
- Maybe use the [deface gem](https://github.com/spree/deface) rather than replacing whole views/partials?