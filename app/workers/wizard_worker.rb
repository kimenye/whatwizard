class WizardWorker
	include Sidekiq::Worker
	sidekiq_options :queue => :wizard, :retry => false

	def perform wizard_id, contact_id
		wizard = Wizard.find wizard_id
		contact = Contact.find contact_id

		if !contact.nil? && !contact.bot_complete
			last_progress = Progress.where(contact_id: contact.id).last
			if last_progress.step.wizard == wizard
				time_since = (Time.now - last_progress.created_at) / 60 # in minutes
				if time_since >= wizard.restart_in
					wizard.reset contact
				end
			end
		end
	end
end