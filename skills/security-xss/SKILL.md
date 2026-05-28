---
name: security-xss
description: Apply XSS protection to Avesta views (app/views/) and React views (web/js/src/). Use when editing views or when end-user HTML must be rendered; follows .agent/rules/security-xss.mdc.
---

# Avesta View XSS Protection
If you are working on a file under the 'app/views' directory with the 'html' file extension, this is an Avesta view.
Follow the instructions in this document to ensure HTML entity encoding is applied to prevent XSS vulnerabilities:

Parameters returned by a controller are rendered in views using braces around the PHP variable being rendered, for example:
```html
<html>
  <p1>{$parameter}</p1>
</html>
```

## Unsafe Filters
Avesta supports optional rendering filters which affect the encoding of the output.
Filters are declared in front of the parameter name followed by a colon, for example: `{s:$foo}` applies the 's' filter to the '$foo' parameter.

Rendered parameters with no filter are always SAFE, for example `{$foo}`.

The 'h' filter is DANGEROUS and should NEVER be used.
If the 'h' filter is encountered, fix the code to use the code by removing the 'h' filter. For example, convert `{h:$foo}` to `{$foo}`.

The following filter should be avoided unless absolutely necessary for the product usecase: `safeh`
If this filter is encountered, suggest removing it and consulting with the Security team for more information.
Do not generate code that uses the `safeh` filter.

# User provided HTML has to be rendered by the application

If the application needs to render user provided HTML as a product requirement, for example, for an HTML template editor, user-provided HTML must be sanitized by the SaferParser class on the backend or DomPurify on the frontend.

## Backend Santization in PHP
Read the SaferParser class at `modules/avesta/src/Avesta/HTML/SaferParser.php` to understand it, and apply it to the user input. For example:
```php
$safer_parser = (new \Avesta\HTML\SaferParser())
->withDefaults()
->withAllowedStyles()
->withAllowedImages()
->withAllowedCSS()
->withAllowedFullPage()
->withAllowedTags(['meta']);

$sanitized = $safer_parser->parse($user_input);
```
SaferParser uses a builder pattern. From the context given to you, determine which configurations should be applied to the parser instance based on the use case.
Configurations are applied by functions starting with `withAllowed` in that class, such as `withAllowedStyles`.

## Frontend Sanitization in JavaScript
If user input is rendered entirely in front-end code (Javascript), sanitize it with DomPurify:
```
const DOMPurify = require('dompurify'); 
render() {
    const sanitizedData = DOMPurify.sanitize(data);
}
```

# React View XSS Protection
If you are working on a file under the 'web/js/src' directory with the 'js' file extension, this is a React view.
Follow the instructions in this section to ensure XSS vulnerabilities are not introduced into React views.

## Avoid Using dangerouslySetInnerHTML
Whenever possible, avoid the `dangerouslySetInnerHTML` function entirely. Do not generate code like this:
`return (<p dangerouslySetInnerHTML={{__html: review}}></p>);`

Instead, use React components that represent the HTML in JSX.
For cases where the user insists that the product requirements absolutely necessitate using `dangerouslySetInnerHTML`, apply DomPurify to sanitize the output:
`return (<p dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(review)}}></p>);`

## Avoid innerHTML
Do not use the `innerHTML` function.
If the data being inserted into the DOM is not HTML but plain text, you can instead use the `innerText` function.

```
componentDidMount() {
    fetch('https://mailchimp.com/profile?username=' +   this.props.name).then(response => {
        return response.json();
    }).then(json => {
        this.ref.current.innerText = profileData;
    }).catch(error);
}
```

For cases, where the user insists that the product requirements absolutely necessitate using `innerHTML`, use DOMPurify to sanitize the data and remove any potentially malicious elements before it is rendered on the page:
```
const DOMPurify = require('dompurify');

componentDidMount() {
    fetch('https://mailchimp.com/profile?username=' +   this.props.name).then(response => {
        return response.json();
    }).then(json => {
        this.ref.current.innerHTML = DOMPurify.sanitize(profileData);
    }).catch(error);
}
```

## User controlled URLs
When dynamically creating URLs, do not allow the user to control the URL protocol or origin.
If the situation requires that the user have full control over a URL that is inserted into the DOM, DOMPurify should be used to sanitize the output and remove any potentially unsafe URLs:

```
const DOMPurify = require('dompurify');
 
render() {
    const anchor = `<a href={url}>Click me!</a>`
    const sanitizedAnchor = DOMPurify.sanitize(anchor);
    return (
        <div>
            {sanitizedAnchor}
        </div>
    )
}
```

## JSX and React.createElement
As a rule of thumb, avoid passing properties via JSX or `createElement` that are completely user-controllable:
- Avoid allowing the user to define the type of the element if they also are able to define the props or children of the element.
  - If the user is allowed to define the type, create an allow-list of expected types and ensure it's within that list.
- Only pass user input to the value of props; avoid allowing users to define both the name and value for a property.
  - If passing user controllable input to a property value, follow previous guidance on how to handle that value properly based on the property being used, i.e. guidance on URLs for the `href`, `src` and `srcset` properties or guidance on `dangerouslySetInnerHTML`.

For example, do not allow expansion of properties like so if `this.state.userPreferences` can be controlled by a user since this allows defining both the name and value of a property:
```
render() {
    return (
        <Profile {...this.state.userPreferences} />
    )
}
```
Instead, set properties individually by hardcoding the names in the JSX and referencing only the values.
