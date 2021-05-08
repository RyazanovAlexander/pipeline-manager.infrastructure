# ------------------------------------------------------------------------------
#  deploy

.PHONY: deploy
deployo:
	@skaffold dev --port-forward

# ------------------------------------------------------------------------------
#  delete

.PHONY: delete
delete:
	@skaffold delete