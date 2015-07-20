class WizardWorker
	include Sidekiq::Worker
	sidekiq_options :queue => :wizard, :retry => false

	def perform progress_id
		progress = Progress.find progress_id
		wizard = progress.step.wizard
		contact = progress.contact

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