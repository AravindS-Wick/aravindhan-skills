---
name: generate-mc-trx-email
description: Generate a new Mailchimp transactional email template set (HTML, txt, metadata). Use when the user asks to generate a transactional email, create an email template, or add a trx email.
disable-model-invocation: true
---

# Generate Mailchimp Transactional Email

## Overview
Generate a new transactional email template set following Mailchimp's email template standards. See `.agent/rules/transactional-email-html.mdc` for usage patterns.

## Required Information

**Gather the following from the user before proceeding:**

1. **Template Name** (snake_case): e.g., `my_new_email_template`
2. **Display Name**: Human-readable name, e.g., "My New Email Template"
3. **Email Type**: One of:
   - `Transactional (No Opt)` - User cannot opt out
   - `Transactional (Opt In/Out)` - User can opt in/out
   - `Time-based Send` - Scheduled sends
4. **Description/Notes**: Brief description of when this email is sent
5. **Category**: e.g., `user notification`, `billing`, `compliance`, `onboarding`, `security`, `access`, `mcco`, `GDPR`, `audiences`, etc.
6. **Active**: Usually `Y` (yes) or `N` (no)
7. **Subject Line**: The email subject
8. **Preview Text**: Short preview text for email clients
9. **Email Content**: Main body content (headline, body paragraphs, CTA button text and URL)
10. **Merge Variables** (optional at this stage): List of dynamic variables needed (e.g., `*|USERNAME|*`, `*|ACCOUNT_NAME|*`)

> **Note on Merge Variables:** There are two types of merge variables:
> - **Data merge variables**: Dynamic data like `*|USERNAME|*`, `*|ACCOUNT_NAME|*`, `*|CTA_URL|*`
> - **Translation merge variables**: Translatable strings like `*|HEADING_TEXT|*`, `*|BODY_TEXT|*`, `*|CTA_TEXT|*`
>
> **You don't need all merge variables defined upfront.** If merge variables aren't available yet, use the hardcoded text from the design. The template can be updated later to use merge variables when they're ready. This should not block template creation.

## Files to Create/Update

### 1. Create Template Folder

Create folder: `data/email_templates/{template_name}/`

### 2. Create `email.html`

Use the template structure from `.agent/rules/transactional-email-html.mdc`. The HTML should include:

- Transaction ID comment: `<!-- trx_XXXX -->` (next available ID)
- Standard reset and client-specific styles
- Mobile responsive media queries (480px breakpoint)
- Mailchimp logo
- Headline (H1 with Georgia serif font stack)
- Body content (Helvetica Neue sans-serif font stack)
- CTA button (usually teal #017E89)
- Standard footer with copyright, Contact Us, Terms of Use, Privacy Policy

**Example HTML structure:**

```html
<!doctype html>
<html>
    <head>
        <!-- trx_XXXX -->
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>*|SUBJECT|*</title>

        <style type="text/css">
            /*////// RESET STYLES //////*/
            p{margin:1em 0;}
            a{word-wrap:break-word;}
            table{border-collapse:collapse;}
            h1, h2, h3, h4, h5, h6{display:block; margin:0; padding:0;}
            img, a img{border:0; height:auto; outline:none; text-decoration:none;}
            body, #bodyTable, #bodyCell{height:100%; margin:0; padding:0; width:100%;}

            /*////// CLIENT-SPECIFIC STYLES //////*/
            img{-ms-interpolation-mode:bicubic;}
            table{mso-table-lspace:0pt; mso-table-rspace:0pt;}
            p, a, li, td, blockquote{mso-line-height-rule:exactly;}
            a[href^="tel"], a[href^="sms"]{color:inherit; cursor:default; text-decoration:none;}
            p, a, li, td, body, table, blockquote{-ms-text-size-adjust:100%; -webkit-text-size-adjust:100%;}
            a[x-apple-data-detectors]{color:inherit !important; text-decoration:none !important; font-size:inherit !important; font-family:inherit !important; font-weight:inherit !important; line-height:inherit !important;}

            /*////// EMAIL STYLES //////*/
            #bodyCell{padding-top:20px !important; padding-right:10px !important; padding-bottom:20px !important; padding-left:10px !important;}
            .emailContainer{max-width:600px;}
            .footerContent a{color:#017E89; font-weight:500; text-decoration:none;}
            #button a{text-decoration:none;}

            @media only screen and (max-width:480px){
                body{width:100% !important; min-width:100% !important;}
                #bodyCell{padding-top:10px !important; padding-bottom:10px !important;}
                h1{font-size:26px !important; line-height:28px !important;}
                .footerContent p{font-size:13px !important; padding-bottom:20px !important;}
                .utilityLink{display:block; font-size:13px !important; padding-top:15px; padding-bottom:15px;}
                .mobileHide{display:none; visibility:hidden;}
            }
        </style>
    </head>
    <body bgcolor="#EFEEEA">
        <center>
            <table align="center" bgcolor="#EFEEEA" border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="bodyTable">
                <tr>
                    <td align="center" style="padding:10px;" valign="top" id="bodyCell">
                        <span style="color:#EFEEEA; display:none; font-size:0px; height:0px; visibility:hidden; width:0px;">*|PREVIEW_TEXT|*</span>
                        <!--[if gte mso 9]>
                        <table align="center" border="0" cellspacing="0" cellpadding="0" style="width:600px;" width="600">
                        <tr>
                        <td align="center" valign="top">
                        <![endif]-->
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="max-width:600px;" width="100%" class="emailContainer">
                            <tr>
                                <td align="center" valign="top">
                                    <!-- BEGIN BODY // -->
                                    <table align="center" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFFFFF; border-radius:0;" width="100%">
                                        <tr>
                                            <td align="center" style="padding-right:24px; padding-left:24px;" valign="top">
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                    <tr>
                                                        <td align="left" valign="top" style="padding-top:40px; padding-bottom:16px;">
                                                            <a href="https://www.mailchimp.com/" target="_blank" style="text-decoration:none;"><img src="https://cdn-images.mailchimp.com/template_images/Mailchimp+Logo+50-50+Black.png" alt="Mailchimp" width="200" class="logoImage" style="border:0; color:#21262A; font-family:'Helvetica Neue', Helvetica, Arial, Verdana, sans-serif; font-size:24px; font-weight:bold; height:auto; letter-spacing:-2px; line-height:100%; text-align:center; outline:none; text-decoration:none;" /></a>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding-bottom:20px;" valign="top">
                                                            <h1 style="color:#21262A; font-family:Georgia, Times, 'Times New Roman', serif; font-size:28px; font-style:normal; font-weight:400; line-height:36px; letter-spacing:normal; margin:0; padding:0; text-align:left;">*|HEADLINE|*</h1>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding-bottom:20px;" valign="top">
                                                            <p style="color:#21262A; font-family:'Helvetica Neue', Helvetica, Arial, Verdana, sans-serif; font-size:16px; font-weight:400; line-height:24px; padding-top:0; margin-top:0; text-align:left;">*|BODY_TEXT|*</p>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" valign="top" style="padding-bottom:60px;">
                                                            <table border="0" cellspacing="0" cellpadding="0">
                                                                <tr>
                                                                    <td align="center" bgcolor="#017E89" id="button" style="border-radius:8px;">
<a href="*|CTA_URL|*" target="_blank" style="border-radius:8px; border:1px solid #017E89; color:#FFFFFF; display:inline-block; font-size:16px; font-family:'Helvetica Neue', Helvetica, Arial, Verdana, sans-serif; font-weight:400; letter-spacing:.3px; padding:20px; text-decoration:none;">*|CTA_TEXT|*</a>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                    <!-- // END BODY -->
                                </td>
                            </tr>
                            <tr>
                                <td align="center" valign="top">
                                    <!-- BEGIN FOOTER // -->
                                    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background:#E2E9ED;">
                                        <tr>
                                            <td align="center" valign="top" class="footerContent" style="color:#6A655F; font-family:'Helvetica Neue', Helvetica, Arial, Verdana, sans-serif; font-size:12px; font-weight:400; line-height:24px; padding-top:40px; padding-bottom:40px; text-align:center;">
                                                <p style="color:#6A655F; font-family:'Helvetica Neue', Helvetica, Arial, Verdana, sans-serif; font-size:12px; font-weight:400; line-height:24px; padding-top:0; margin:0; text-align:center;">&copy; 2001-*|CURRENT_YEAR|* Mailchimp<sup>&reg;</sup> All Rights Reserved<br />*|MC_MAILING_ADDRESS|*</p>
                                                <a href="https://www.mailchimp.com/contact/" target="_blank" style="color:#017E89; font-weight:500; text-decoration:none;" class="utilityLink">Contact Us</a><span class="mobileHide">&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span><a href="https://mailchimp.com/legal/terms/" target="_blank" style="color:#017E89; font-weight:500; text-decoration:none;" class="utilityLink">Terms of Use</a><span class="mobileHide">&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span><a href="https://mailchimp.com/legal/privacy/" target="_blank" style="color:#017E89; font-weight:500; text-decoration:none;" class="utilityLink">Privacy Policy</a>
                                            </td>
                                        </tr>
                                    </table>
                                    <!-- // END FOOTER -->
                                </td>
                            </tr>
                        </table>
                        <!--[if gte mso 9]>
                        </td>
                        </tr>
                        </table>
                        <![endif]-->
                    </td>
                </tr>
            </table>
        </center>
    </body>
</html>
```

### 3. Create `email.txt`

Plain text version of the email. Key formatting rules:

- **Hyperlinks**: Always in parentheses, e.g., `(https://www.mailchimp.com)`
- **Button area**: 20 dashes (`--------------------`) above and below the button text/URL
- **Footer separator**: 30 dashes (`------------------------------`) to separate footer from body
- **No HTML or special characters**: This is plain text only

**Example structure:**

```
Headline

Body content goes here. Hyperlinks in plain text layouts are always in parentheses like this (https://www.mailchimp.com).

Additional paragraph content as needed.

--------------------
Button Text: https://mailchimp.com/link_to_button
--------------------


------------------------------
https://www.mailchimp.com
*|MC_MAILING_ADDRESS|*

Contact Us: https://www.mailchimp.com/contact/
Terms of Use: https://mailchimp.com/legal/terms/
Privacy Policy: https://mailchimp.com/legal/privacy/
```

> **Note:** Not having all merge variables should not block creating the `.txt` file. Use hardcoded text from the design.
>
> Some templates may have extra buttons, lists, or other layout items that don't fit this standard schema. For those cases, keep in mind this is plain text with no HTML or special characters. Reference existing `.txt` files in `data/email_templates/` for guidance on handling non-standard layouts.

### 4. Create `metadata.ini`

```ini
type = "Transactional (No Opt)"
name = "Display Name Here"
id = "trx_XXXX"
active = "Y"
notes = "Description of when this email is sent"
category = "user notification"
```

### 5. Update `data/email_templates/metadata.yaml`

Add entry at the end:

```yaml
template_name:
  name: Display Name Here
  type: Transactional (No Opt)
  id: trx_XXXX
  active: Y
  notes: Description of when this email is sent
  category: user notification
```

**Note:** Find the next available `trx_XXXX` ID by checking the highest ID currently in the file and incrementing by 1.

### 6. Update `tests/transactional-emails/test_merge_vars.php`

Add a test function at the appropriate location (either alphabetically or at the end before the closing):

```php
/**
 * @db off
 */
function test_template_name()
{
    $mail = new MC_Mail();
    $mail->setBodyTemplate(
        "template_name",
        [
            'MERGE_VAR_1' => 'Test Value 1',
            'MERGE_VAR_2' => 'Test Value 2',
            // Add all merge variables used in the template
        ]
    );
    $mail->systemSend();
}
```

> **Note:** If merge variables aren't available yet and you can't write a complete test, you can temporarily exclude the template from the test suite by adding it to the `$excluded` array at the top of `test_merge_vars()`:
>
> ```php
> $excluded = [
>     // ... existing exclusions ...
>     "/your_template_name",  // TODO: Add test when merge vars are ready
> ];
> ```
>
> This should not block template creation. Remember to remove the exclusion and add a proper test function once the merge variables are defined.

**Important:** The test function name must be `test_` followed by the template name with:
- `/` replaced with `__` (double underscore)
- `-` replaced with `_` (single underscore)

Example: `branded_domains/error/issuing` → `test_branded_domains__error__issuing`

## Checklist

Before completing, verify:

- [ ] Folder created: `data/email_templates/{template_name}/`
- [ ] `email.html` created with correct trx_ID comment
- [ ] `email.txt` created
- [ ] `metadata.ini` created with unique trx_ID
- [ ] `metadata.yaml` updated with new entry
- [ ] Test function added to `test_merge_vars.php`
- [ ] All merge variables are documented and included in test
- [ ] HTML follows Mailchimp email guidelines (table-based, inline styles, mobile responsive)

## Common Merge Variables

There are two types of merge variables:

### Data Merge Variables
Dynamic data populated at send time:

- `*|CURRENT_YEAR|*` - Current year (e.g., 2024)
- `*|MC_MAILING_ADDRESS|*` - Mailchimp mailing address
- `*|USERNAME|*` - User's username
- `*|FNAME|*` - User's first name
- `*|LNAME|*` - User's last name
- `*|ACCOUNT_NAME|*` - Account name
- `*|EMAIL_ADDRESS|*` - User's email
- `*|UID|*` or `*|USERID|*` - User ID
- `*|CTA_URL|*` - Call-to-action URL

### Translation Merge Variables
Translatable strings that support i18n:

- `*|SUBJECT|*` - Email subject line
- `*|PREVIEW_TEXT|*` - Preview text for email clients
- `*|HEADLINE|*` or `*|HEADING_TEXT|*` - Main headline
- `*|BODY_TEXT|*` - Body content
- `*|CTA_TEXT|*` - Button text
- `*|CONTACT_US|*`, `*|TERMS_OF_USE|*`, `*|PRIVACY_POLICY|*` - Footer links

### Using Hardcoded Text

If merge variables aren't available yet, you can use hardcoded text directly in the template:

```html
<!-- Instead of merge variable -->
<h1>*|HEADLINE|*</h1>

<!-- Use hardcoded text from design -->
<h1>Your account has been updated</h1>
```

The template can be updated later to use merge variables when translation/data systems are ready.

## References

- See `.agent/rules/transactional-email-html.mdc` for complete HTML email guidelines
- Existing templates in `data/email_templates/` for examples
- Test patterns in `tests/transactional-emails/test_merge_vars.php`

