# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class UnzipJob < ActiveFedoraPidBasedJob
  def queue_name
    :unzip
  end

  def run
    Zip::Archive.open_buffer(object.content.content) do |archive|
      archive.each do |f|
        if f.directory?
          create_directory(f)
        else
          create_file(f)
        end
      end
    end
  end

  protected

  # Creates a GenericFile object based on +file+
  # @param file [Zip::File]
  def create_file(file)
    @generic_file = GenericFile.new
    @generic_file.batch_id = object.batch.pid
    @generic_file.add_file(file.read, 'content', file.name)
    @generic_file.apply_depositor_metadata(object.edit_users.first)
    @generic_file.date_uploaded = Time.now.ctime
    @generic_file.date_modified = Time.now.ctime
    @generic_file.save
  end
  
  # Creates representation of directory corresponding to +file+
  # Default behavior: _do nothing_
  # @param file [Zip::File]
  def create_directory(file)
  end

end
