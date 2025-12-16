## Access Contract Change

### Type of Change
<!-- Check one -->
- [ ] 🆕 New access contract (new use case onboarding)
- [ ] 📝 Update existing contract (policy change, add services)
- [ ] 🗑️ Remove contract (decommissioning use case)

### Contract Details

**Folder:** `contracts/<!-- folder-name -->`
**Business Unit:** 
**Use Case Name:** 
**Environment:** 

### Changes Made

<!-- What did you add/change/remove? -->



### Validation

- [ ] `usecase.bicepparam` has correct hub APIM coordinates
- [ ] Target Key Vault exists and is accessible
- [ ] API names in `apiNameMapping` exist in APIM
- [ ] Custom `policy.xml` reviewed (if applicable)

### For Platform Team Reviewers

- [ ] Business justification is clear
- [ ] Resource naming follows conventions
- [ ] Policy is appropriate for use case
- [ ] No security concerns
- [ ] Ready to deploy

---

_This PR will be automatically deployed on merge to main._
