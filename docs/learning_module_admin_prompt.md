# Learning Module — Firestore Schema & Admin Website Prompt

The PakFasal app's **Learning module** (YouTube Videos, Keera aur Bimariyan,
Learning Articles) now reads its content live from **Cloud Firestore**,
project `pakfasalapp` — the same Firebase project the admin website already
connects to. No new backend is needed.

This document has two parts:

1. The exact Firestore schema the app expects (collections + fields).
2. A ready-to-paste prompt for your admin website describing the forms to
   build for managing this content.

---

## 1. Firestore schema

All text content that appears in the app comes in **two parallel fields**,
one per language: an `...En` (English) field and an `...Ur` (Urdu) field.
The app picks whichever matches the user's selected language, and falls back
to English if the Urdu field is empty.

### Collection: `learning_crops`

One document per crop, used by the "Keera aur Bimariyan" module.

| Field | Type | Required | Notes |
|---|---|---|---|
| Document ID | string | yes | Lowercase slug, e.g. `wheat`, `rice`, `cotton`, `sugarcane`, `maize`. Used as a foreign key by other collections. Cannot be changed after creation without also updating referencing documents. |
| `nameEn` | string | yes | e.g. `Wheat` |
| `nameUr` | string | yes | e.g. `گندم` |
| `icon` | string (enum) | yes | One of the icon keys below |
| `order` | number | yes | Controls display order (ascending) |
| `showInPests` | boolean | yes | Show this crop in the "Keera aur Bimariyan" crop grid |

**Icon enum** (dropdown, fixed list — do not allow free text):
`grass`, `rice_bowl`, `cotton`, `spa`, `grass_outlined`, `eco`, `terrain`,
`science`, `water_drop`, `cloud`, `storefront`, `account_balance`,
`bug_report`, `agriculture`, `article`

### Collection: `learning_crop_diseases`

One document per pest/disease.

| Field | Type | Required | Notes |
|---|---|---|---|
| Document ID | string | auto-generated is fine | |
| `cropId` | string | yes | Must match a document ID in `learning_crops` (render as a dropdown populated from that collection, not free text) |
| `order` | number | yes | Display order within the crop |
| `nameEn` / `nameUr` | string | yes | e.g. `Leaf Curl Virus` / `لیف کرل وائرس` |
| `descriptionEn` / `descriptionUr` | string | yes | One short sentence |
| `symptomsEn` / `symptomsUr` | array of strings | yes | Admin enters as a multi-line textarea, **one bullet per line**; the form should split on newline into an array before saving |
| `solutionsEn` / `solutionsUr` | array of strings | yes | Same multi-line-textarea-to-array pattern |

### Collection: `learning_articles`

One document per article.

| Field | Type | Required | Notes |
|---|---|---|---|
| Document ID | string | auto-generated is fine | |
| `categoryEn` / `categoryUr` | string | yes | e.g. `Soil & Land` / `زمین`. Free text, but suggest reusing existing categories via a combo box so the app's category filter chips don't fragment |
| `titleEn` / `titleUr` | string | yes | |
| `summaryEn` / `summaryUr` | string | yes | 1–2 sentence teaser shown in the list and at the top of the article |
| `readTimeMinutes` | number | yes | Just a number, e.g. `4`. The app formats "4 min read" / "4 منٹ کا مطالعہ" automatically — no need for separate text fields |
| `icon` | string (enum) | yes | Same icon list as crops |
| `order` | number | yes | Display order |

### Collection: `learning_article_sections`

One document per heading+paragraph block inside an article (typically 3–5
per article).

| Field | Type | Required | Notes |
|---|---|---|---|
| Document ID | string | auto-generated is fine | |
| `articleId` | string | yes | Dropdown from `learning_articles` |
| `order` | number | yes | 1, 2, 3… controls ordering within the article |
| `headingEn` / `headingUr` | string | yes | Section heading |
| `bodyEn` / `bodyUr` | string (long text) | yes | Full paragraph, textarea |

---

## 2. Prompt for your admin website

Paste the block below into your admin website project (as instructions for
whatever tool/developer maintains it). It assumes the admin website already
has Firebase/Firestore initialized against project `pakfasalapp`.

> Add a new "Learning Content" section to the admin panel with 4 management
> screens, each backed by its own Firestore collection. Every screen should
> support **list, add, edit, and delete**, and every screen editing content
> that appears in the mobile app must show **English and Urdu inputs
> side-by-side (or stacked) for every translatable field** — never a single
> language-agnostic field for user-facing text.
>
> **1. Crops** (`learning_crops`, doc ID = crop slug you type, e.g. `wheat`)
> - Text input: Crop ID / slug (lowercase, no spaces — only editable when
>   creating a new crop, disabled when editing an existing one)
> - Text input: Name (English), Text input: Name (Urdu)
> - Dropdown: Icon — options: grass, rice_bowl, cotton, spa, grass_outlined,
>   eco, terrain, science, water_drop, cloud, storefront, account_balance,
>   bug_report, agriculture, article
> - Number input: Display order
> - Toggle: Show in "Pests & Diseases" module
>
> **2. Pests & Diseases** (`learning_crop_diseases`)
> - Dropdown: Crop — populated live from the `learning_crops` collection,
>   showing each crop's English name, saving its document ID as `cropId`
> - Number input: Display order (within this crop)
> - Text input: Disease/pest name (English), Text input: same (Urdu)
> - Text input: Short description, 1 sentence (English), same (Urdu)
> - Textarea: Symptoms (English) — one symptom per line
> - Textarea: Symptoms (Urdu) — one symptom per line
> - Textarea: Treatment/solutions (English) — one tip per line
> - Textarea: Treatment/solutions (Urdu) — one tip per line
> - On save: split every textarea on newlines into a trimmed array of
>   non-empty strings before writing `symptomsEn`, `symptomsUr`,
>   `solutionsEn`, `solutionsUr` to Firestore
> - List view: group/sort rows by crop, then by order, so admins can see a
>   given crop's full disease list together
>
> **3. Articles** (`learning_articles`)
> - Text input: Category (English/Urdu) — ideally an editable combo box
>   that suggests categories already used by other articles, to avoid
>   accidentally creating near-duplicate categories
> - Text input: Title (English/Urdu)
> - Textarea: Summary, 1–2 sentences (English/Urdu)
> - Number input: Estimated read time in minutes (just a number, e.g. `5`)
> - Dropdown: Icon — same list as crops
> - Number input: Display order
>
> **4. Article Sections** (`learning_article_sections`)
> - Dropdown: Article — populated from `learning_articles`, showing each
>   article's English title, saving its document ID as `articleId`
> - Number input: Section order (1, 2, 3…)
> - Text input: Section heading (English/Urdu)
> - Textarea: Section body, full paragraph (English/Urdu)
> - List view: group/sort by article, then by order — ideally editable
>   directly from within the article's edit screen as repeatable
>   sub-fields, if your form framework supports nested/repeater fields
>
> General requirements for all 4 screens:
> - Validate that every required field is non-empty before saving.
> - Show a live preview or at least a read-only summary list so a
>   non-technical admin can see what's already entered without opening
>   Firestore directly.
> - Do not let users type arbitrary values into the Icon or Crop/Article
>   dropdown fields — always constrain them to the fixed lists / existing
>   documents described above, since the app will silently fall back to a
>   default icon (and skip rows with an unknown `cropId`/`articleId`) if
>   these don't match.
> - The mobile app caches fetched content locally and only re-fetches when
>   the user pulls-to-refresh, so changes may take a short refresh to show
>   up for users already using the app — this is expected, not a bug.

---

## 3. Firestore security rules

There's no `firestore.rules` file tracked in the app repo — rules for this
project are managed directly in the **Firebase Console → Firestore Database
→ Rules** tab. Add (merge into your existing rules, don't replace them)
something like:

```
match /learning_crops/{docId} {
  allow read: if true;
  allow write: if request.auth != null; // tighten to your admin check
}
match /learning_crop_diseases/{docId} {
  allow read: if true;
  allow write: if request.auth != null;
}
match /learning_articles/{docId} {
  allow read: if true;
  allow write: if request.auth != null;
}
match /learning_article_sections/{docId} {
  allow read: if true;
  allow write: if request.auth != null;
}
```

Content is public read (anyone using the app, signed in or not, can view
it) and write-protected. If your admin website's users sign in with Firebase
Auth, `request.auth != null` is enough as a starting point; if you want to
restrict writes to specific admin accounts, add a custom claim (e.g.
`request.auth.token.admin == true`) or check against an `admins` collection.
If your admin website instead writes via a trusted backend using the
**Firebase Admin SDK** (not the client SDK), that bypasses these rules
entirely, and you can set `allow write: if false;` for all four collections
above to fully lock out client-side writes.

---

## 4. Starter content

The bilingual starter content that used to ship hardcoded in the app (5
crops, ~15 diseases, 6 articles with 24 sections) has already been pushed
into these Firestore collections once, so the module isn't empty. The
one-time, debug-only "seed sample content to Firestore" developer tool that
used to write this data has since been removed from the app — all further
content changes should be made directly through the admin website described
in section 2 above.
