module Workflows
  class YAMLToWorkflowsService
    def initialize(yaml_file:, scm_webhook:, token:, workflow_run:)
      @yaml_file = yaml_file
      @scm_webhook = scm_webhook
      @token = token
      @workflow_run = workflow_run
    end

    def call
      create_workflows
    end

    private

    def create_workflows
      begin
        parsed_workflows_yaml = YAML.safe_load(File.read(@yaml_file))
      rescue Psych::SyntaxError => e
        raise Token::Errors::WorkflowsYamlNotParsable, "Unable to parse #{@token.workflow_configuration_path}: #{e.message}"
      end

      parsed_workflows_yaml
        .map do |_workflow_name, workflow_instructions|
        Workflow.new(workflow_instructions: workflow_instructions, scm_webhook: @scm_webhook, token: @token,
                     workflow_run: @workflow_run)
      end
    end
  end
end
