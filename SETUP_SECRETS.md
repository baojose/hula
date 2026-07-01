# Public repository — credentials (read this first)

This tree is a **sanitized** snapshot: Firebase, Twitter, Fabric, and social app IDs in source are **placeholders**. You must inject **real** values from your **private** configuration or from each provider’s console before the app will behave like production.

## If these credentials ever appeared in public git history

**Assume they are compromised.** Do not rely on “hiding” the repository:

1. **Twitter / X** — create new app keys or rotate consumer key & secret in the developer portal.
2. **Firebase / Google** — in Google Cloud Console, **restrict** the iOS API key (bundle ID); consider **rotating** keys. Download a fresh `GoogleService-Info.plist` and keep it **out of public repos** if possible.
3. **Facebook** — treat app ID as public metadata; **rotate the app secret** if it was ever committed; review app settings.
4. **LinkedIn** — rotate the OAuth app secret/state if they ever appeared in git history. Set `LIAppId`, `LIAppSecret`, `LIState`, `LIRedirectURL`, and the `li<app id>` URL scheme from a private build configuration.
5. **Fabric** — legacy; if you still run the Run Script build phase, replace placeholders with your own values or remove Fabric entirely.

## Making this repo private

If this code is not meant to be public, turn the GitHub repository **Private** in repository settings — that reduces scraping and casual cloning (it is not a substitute for rotating leaked keys).
