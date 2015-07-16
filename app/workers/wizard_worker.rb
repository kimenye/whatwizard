class WizardWorker
	include Sidekiq::Worker
	sidekiq_options :queue => :wizard, :retry => false

	def perform wizard_id, contact_id, progress_id
		wizard = Wizard.find wizard_id
		contact = Contact.find contact_id

		logger.info ">>>>>>>>>> Hello"

		if !contact.nil? && !contact.bot_complete
			logger.info ">>>>>>>>>> Found contact"
			last_progress = Progress.where(contact_id: contact.id).last
			logger.info "#{progress_id} - #{last_progress.id}"
			if last_progress.step.wizard == wizard
				logger.info ">>>>>>>>>> Found wizard"
				# time_since = (Time.now - last_progress.created_at) / 60 # in minutes
				if progress_id == last_progress.id
					logger.info ">>>>>>>>>> Time to reset"
					wizard.reset contact
				end
			end
		end
	end
end