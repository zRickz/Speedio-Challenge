Rails.application.config.after_initialize do
  ProcessCompaniesJob.perform_now
end
