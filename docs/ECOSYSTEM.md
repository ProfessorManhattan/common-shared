# Megabyte Labs Ecosystem

This project incorporates design patterns from the [Megabyte Labs](https://megabyte.space) ecosystem. The ecosystem is a set of repositories that integrate with one another through CI/CD. The repositories share configurations, common documentation partials, and developer tools. The ecosystem's main goals are to:

1. Keep projects up-to-date
2. Make the management of large amounts of repositories easy
3. Be prepared by implementing development features before they are necessary (within reason)
4. Maximize developer efficiency
5. Improve developer onboarding by providing the tools necessary to adhere to the design patterns of the ecosystem with minimal oversight
6. Serve and provide an example of a bleeding-edge, production-ready full-stack development platform

## Language Support

There are currently boilerplates and templates written in the following languages:

* TypeScript (preferred language)
* Python (first-class support - currently dominating AI)
* Go (first-class support - easy, performant system tools with a large community backing it)

First-class support includes ensuring boilerplates, CI pipelines, and tooling is best-in-class, with no visible stone unturned. We also, leisurely, support the following languages:

* PHP (required for WordPress and Laravel)
* Java (day jobs always seem to heavily use Java and Cordova Android plugins sometimes require adjustments)
* Ruby
* Rust

With these second tier languages, you might expect to see a couple linters added to the CI pipelines and perhaps a few supporting libraries but not meticulously optimized-for like TypeScript, Python, and Go.

Other languages may be required from time-to-time. C is sometimes required by Arduino. That all said, if you are working with this ecosystem, keep in mind our goal of providing first-class support for TypeScript, Python, and Go.
