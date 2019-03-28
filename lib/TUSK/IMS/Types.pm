# Copyright 2013 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package TUSK::IMS::Types;

###########
# * Imports
###########

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

#########
# * Setup
#########

use Type::Library
    -base,
    -declare => qw(
       Manifest
       ManifestMetadata
       ManifestLOM
       ManifestGeneral
       ManifestTitle
       ManifestString
       ManifestLifeCycle
       ManifestContribute
       ManifestDate
       ManifestDatetime
       ManifestRights
       ManifestCopyright
       ManifestValue
       ManifestDescription
       Organization
       Resources
       ManifestResource
       ResourceFile
       ResourceDependency
       Questestinterop
       QTIQuiz
       QTIAssessment
       QTISection
       QTIAssignment
       QTIItems
       QTIItem
       QTIMetadata
       Material
       MaterialText
       FlowMaterial
       Presentation
       ItemMetadata
       ResponseProcessing
       ResponseOutcomes
       ResponseCondition
       ResponseLid
       ResponseString
       ResponseLabel
       RenderChoice
       RenderFillInBlank
       ConditionVariable
       DeclareVariable
       SetVariable
       VariableEqual
       ItemFeedback
       DisplayFeedback
);

use Type::Utils -all;
use Types::Standard qw( Int Str ArrayRef );
#use TUSK::LOM::Types qw( LOM );

### imsmanifest.xml
class_type Manifest, { class => 'TUSK::IMS::Manifest' };
class_type ManifestLOM, { class => 'TUSK::IMS::Manifest::LOM' };
class_type ManifestGeneral, { class => 'TUSK::IMS::Manifest::General' };
class_type ManifestTitle, { class => 'TUSK::IMS::Manifest::Title' };
class_type ManifestString, { class => 'TUSK::IMS::Manifest::String' };
class_type ManifestLifeCycle, { class => 'TUSK::IMS::Manifest::LifeCycle' };
class_type ManifestContribute, { class => 'TUSK::IMS::Manifest::Contribute' };
class_type ManifestDate, { class => 'TUSK::IMS::Manifest::Date' };
class_type ManifestDatetime, { class => 'TUSK::IMS::Manifest::Datetime' };
class_type ManifestRights, { class => 'TUSK::IMS::Manifest::Rights' };
class_type ManifestCopyright, { class => 'TUSK::IMS::Manifest::Copyright' };
class_type ManifestDescription, { class => 'TUSK::IMS::Manifest::Description' };
class_type ManifestValue, { class => 'TUSK::IMS::Manifest::Value' };
class_type ManifestMetadata, { class => 'TUSK::IMS::Manifest::Metadata' };
class_type Organization, { class => 'TUSK::IMS::Manifest::Organization' };
class_type Resources, { class => 'TUSK::IMS::Manifest::Resources' };
class_type ManifestResource, { class => 'TUSK::IMS::Manifest::Resource' };
class_type ResourceFile, { class => 'TUSK::IMS::Manifest::Resource::File' };
class_type ResourceDependency, { class => 'TUSK::IMS::Manifest::Resource::Dependency' };

### assessment_meta.xml
class_type QTIQuiz, { class => 'TUSK::IMS::QTI::Quiz' };
class_type QTIAssignment, { class => 'TUSK::IMS::QTI::Assignment' };

### quiz questions xml
class_type Questestinterop, { class => 'TUSK::IMS::QTI::Questestinterop' };
class_type QTIAssessment, { class => 'TUSK::IMS::QTI::Assessment' };
class_type QTISection, { class => 'TUSK::IMS::QTI::Section' };
class_type QTIItems, { class => 'TUSK::IMS::QTI::Items' };
class_type QTIItem, { class => 'TUSK::IMS::QTI::Item' };
class_type QTIMetadata, { class => 'TUSK::IMS::QTI::Metadata' };
class_type Material, { class => 'TUSK::IMS::QTI::Material' };
class_type MaterialText, { class => 'TUSK::IMS::QTI::Material::Text' };
class_type FlowMaterial, { class => 'TUSK::IMS::QTI::Material::Flow' };
class_type Presentation, { class => 'TUSK::IMS::QTI::Presentation' };
class_type ItemMetadata, { class => 'TUSK::IMS::QTI::Metadata::Item' };
class_type ResponseProcessing, { class => 'TUSK::IMS::QTI::Response::Processing' };
class_type ResponseOutcomes, { class => 'TUSK::IMS::QTI::Response::Outcomes' };
class_type ResponseCondition, { class => 'TUSK::IMS::QTI::Response::Condition' };
class_type ResponseLid, { class => 'TUSK::IMS::QTI::Response::Lid' };
class_type RenderChoice, { class => 'TUSK::IMS::QTI::Render::Choice' };
class_type RenderFillInBlank, { class => 'TUSK::IMS::QTI::Render::FillInBlank' };
class_type ResponseString, { class => 'TUSK::IMS::QTI::Response::String' };
class_type ResponseLabel, { class => 'TUSK::IMS::QTI::Response::Label' };
class_type ConditionVariable, { class => 'TUSK::IMS::QTI::Variable::Condition' };
class_type DeclareVariable, { class => 'TUSK::IMS::QTI::Variable::Declare' };
class_type SetVariable, { class => 'TUSK::IMS::QTI::Variable::Set' };
class_type VariableEqual, { class => 'TUSK::IMS::QTI::Variable::Equal' };
class_type ItemFeedback, { class => 'TUSK::IMS::QTI::Feedback::Item' };
class_type DisplayFeedback, { class => 'TUSK::IMS::QTI::Feedback::Display' };


1;
