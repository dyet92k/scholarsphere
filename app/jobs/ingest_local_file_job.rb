# frozen_string_literal: true

class IngestLocalFileJob < ApplicationJob
  queue_as CurationConcerns.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] path
  # @param [User] user
  def perform(file_set, path, user)
    file_set.label ||= File.basename(path)

    actor = CurationConcerns::Actors::FileSetActor.new(file_set, user)

    if actor.create_content(File.open(path))
      CurationConcerns.config.callback.run(:after_import_local_file_success, file_set, user, path)
    else
      CurationConcerns.config.callback.run(:after_import_local_file_failure, file_set, user, path)
    end
  end
end
