# Author:: Couchbase <info@couchbase.com>
# Copyright:: 2012 Couchbase, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
module ModelValidations

  # extend class methods when including this module
  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end


  #### INSTANCE METHODS -- each calls ClassMethods, for DRY implementation

  def validate_submit_comment(page_id, comment_text)
    self.class.validate_submit_comment(page_id, comment_text)
  end

  #### CLASS METHODS

  module ClassMethods
    include ModelGlobal

    # Validate radlib text input (array of words)
    def validate_submit_comment(page_id, comment_text)
      raise ArgumentError, :no_page_id unless page_id && page_id.length > 0
      raise ArgumentError, :no_text unless comment_text && comment_text.length > 0
      true
    end



  end # end ClassMethods

end # end module ModelValidations