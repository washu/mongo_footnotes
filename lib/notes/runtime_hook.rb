module MongoFootnotes
  module RuntimeHook
    extend ActiveSupport::Concern

    protected
    attr_internal :mongo_runtime
    def process_action(action, *args)
      Footnotes::Notes::MongoSubscriber.reset_runtime
      super
    end

    def cleanup_view_runtime
      mongo_rt_before_render = Footnotes::Notes::MongoSubscriber.reset_runtime
      runtime = super
      mongo_rt_after_render = Footnotes::Notes::MongoSubscriber.reset_runtime
      self.mongo_runtime = mongo_rt_before_render + mongo_rt_after_render
      runtime - mongo_rt_after_render
    end
  end
end