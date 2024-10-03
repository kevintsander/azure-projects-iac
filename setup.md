# Chess Setup

1. Run Shared Terraform
   - `terraform apply -var-file={env}.tfvars auto-approve=true`
2. Update Key Vault
   1. Grant `Key Vault Secret Officer` role
   1. Create Key Vault Secrets
      - `github-container-registry-password`
      - `chess-sql-server-admin-password`
3. Run Chess Terraform
4. Update database
   - run the following commands
   ```sh
   rails db:create
   rails db:migrate
   ```

things to add:

- how to get access to update db
- how to get access to key vault

https://www.reddit.com/r/Terraform/comments/xkct4r/how_do_i_have_terraform_call_an_azure_key_vault/
