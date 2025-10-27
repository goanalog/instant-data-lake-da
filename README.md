# Instant Data Lake — IBM Cloud Deployable Architecture

**What it is**  
- IBM Cloud Object Storage (Lite) + regional bucket
- Sample CSVs uploaded during `apply`
- Helper App (Flask) built **inside Code Engine**, pushed to ICR, and deployed as a public app
- Returns a **shareable live URL** as the primary output

**Why it’s Catalog-friendly**  
- No external downloads during Docker build
- Code Engine **Build → ICR → App** workflow
- Minimal inputs; clean outputs

## Deploy via IBM Cloud Projects
1. Import this ZIP into **Catalog Management**.
2. In **Projects → Create Configuration**, choose the *Base* variation.
3. Customize (or accept defaults) and provide **ibmcloud_api_key** (sensitive).
4. Deploy → Click **Open Helper App**.
