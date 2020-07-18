# TODOs

# General

1. Allow to save location
1. Keep track of Urlaubstage
1. Connect to time tracking to calculate monthly work hour balance
1. Set up Docker container for deployment
1. Move all credentials to .env
1. Allow to select a single day
1. Ensure production mode for all parts
1. Use Env variable in JS code directly
1. Use release functionality for deployment

## Frontend

1. Improvement: Handle "no input yet" correctly in all cases
  1. Ensure confirmation is reset if confirmed data changes
  1. Allow to change generated location data
  1. Display error messages in a good way
  1. Allow to provide data manually for everything that could not be fetched
    1. Vacation Days
    1. Location Data
1. Some kind of notification for Robin to request Robins signature
1. Validate Signature Presence
1. Remove all Debug entries everywhere and compile with --optimize (depends on backend, because API key)
1. Design
  1. Make layout work for small and large screens
  1. Make it look cool
  1. Improvement: Combine views to have only output view?
1. Retries for failed requests
1. Improvement: Allow to paint "dots" in signature on click
1. Save signature for reuse in localStorage
1. Allow to get vacation data for the next year
1. Create TimeData as a Record
1. Use Task.attempt to get current time and zone



1. Limited Selection for allowed state shorthands for users ✅
1. Create User accounts ✅
1. Implement OAuth with https://medium.com/@rrugamba/setting-up-google-oauth-in-phoenix-9167595f5fb7 or https://dreamconception.com/tech/phoenix-full-fledged-api-in-five-minutes and/or https://levelup.gitconnected.com/how-to-do-oauth-with-github-in-elixir-phoenix-1-5-c2bd5dc05cb1 ✅
1. Create Elixir backend ✅
  1. Secure OpenCageData API KEY ✅
1. Different Status bars for ✅
  1. Location Data ✅
  1. Vacation Days ✅
  1. Filled out Form ✅
1. Show status of generated data ✅
1. Allow to convert all state locations for germany to their shorthands ✅
1. Refactor: Combine dates to range in model ✅
1. Refactor: Use RemoteData ✅
1. Refactor: Use elm-url (https://package.elm-lang.org/packages/elm/url/latest/Url-Builder) ✅
1. Sort vacationDays ✅
1. Prevent clean printing with missing data ✅
1. Work not only for 2020 ✅
1. Refactor: Extract dimensions of signature field ✅
1. Refactor: More similar Msg names ✅
1. Use Elm-UI in Vacation Days ✅
1. Improve spacing with elm UI ✅
1. Longer Tick ✅
1. Ensure calculations are not done unless vacationDays are available ✅
1. Refactor: One Datastructure for LocationInformation, currentLocation and location ✅
1. Feiertage vernünftig anzeigen ✅
1. Use vacation days for calculation Resturlaub ✅
1. Calculation Resturlaub ✅
1. Get city and state from Gelocation for FeiertagsAPI and city for signature ✅
1. Get Geolocation from Browser with ports ✅
1. API für Feiertage im jeweiligen Bundesland (https://feiertage-api.de/api/?jahr=2016&nur_land=NW) ✅
1. Copy layout from Robins PDF ✅
1. Some way for PDF Export ✅
1. Input for dates of the Urlaubsantrag ✅
1. Use Elm UI ✅
1. Nebendran Ausgabe anzeigen ✅
1. Remove Packages ✅

Possible MVP Workflows:

- PDF generation in Elm, Email to Robin
- No PDF generation Robin gets Notification in Slack to look at the generated Antrag.
