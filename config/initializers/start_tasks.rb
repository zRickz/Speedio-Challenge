Rails.application.config.after_initialize do
  ProcessCompaniesJob.perform_later
end
