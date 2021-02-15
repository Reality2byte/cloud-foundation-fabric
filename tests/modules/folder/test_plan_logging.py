# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import os
import pytest

from collections import Counter

FIXTURES_DIR = os.path.join(os.path.dirname(__file__), 'fixture')


def test_sinks(plan_runner):
  "Test folder-level sinks."
  logging_sinks = """ {
    warning = {
      type             = "gcs"
      destination      = "mybucket"
      filter           = "severity=WARNING"
      iam              = true
      include_children = true
    }
    info = {
      type             = "bigquery"
      destination      = "projects/myproject/datasets/mydataset"
      filter           = "severity=INFO"
      iam              = true
      include_children = true
    }
    notice = {
      type             = "pubsub"
      destination      = "projects/myproject/topics/mytopic"
      filter           = "severity=NOTICE"
      iam              = true
      include_children = false
    }
  }
  """
  _, resources = plan_runner(FIXTURES_DIR, logging_sinks=logging_sinks)
  assert len(resources) == 7

  resource_types = Counter([r['type'] for r in resources])
  assert resource_types == {
    'google_bigquery_dataset_iam_binding': 1,
    'google_folder': 1,
    'google_logging_folder_sink': 3,
    'google_pubsub_topic_iam_binding': 1,
    'google_storage_bucket_iam_binding': 1
  }
  
  sinks = [r for r in resources
           if r['type'] == 'google_logging_folder_sink']
  assert sorted([r['index'] for r in sinks]) == [
      'info',
      'notice',
      'warning',
  ]
  values = [(r['index'], r['values']['filter'], r['values']['destination'],
             r['values']['include_children'])
            for r in sinks]
  assert sorted(values) == [
    ('info',
     'severity=INFO',
     'bigquery.googleapis.com/projects/myproject/datasets/mydataset',
     True),
    ('notice',
     'severity=NOTICE',
     'pubsub.googleapis.com/projects/myproject/topics/mytopic',
     False),
    ('warning', 'severity=WARNING', 'storage.googleapis.com/mybucket', True)]

  bindings = [r for r in resources
              if 'binding' in r['type']]
  values = [(r['index'], r['type'], r['values']['role'])
            for r in bindings]
  assert sorted(values) == [
    ('info', 'google_bigquery_dataset_iam_binding', 'roles/bigquery.dataEditor'),
    ('notice', 'google_pubsub_topic_iam_binding', 'roles/pubsub.publisher'),
    ('warning', 'google_storage_bucket_iam_binding', 'roles/storage.objectCreator')
  ]

  
def test_exclusions(plan_runner):
  "Test folder-level logging exclusions."
  logging_exclusions = (
      '{'
      'exclusion1 = "resource.type=gce_instance", '
      'exclusion2 = "severity=NOTICE", '
      '}'
  )
  _, resources = plan_runner(FIXTURES_DIR,
                             logging_exclusions=logging_exclusions)
  assert len(resources) == 3
  exclusions = [r for r in resources
                if r['type'] == 'google_logging_folder_exclusion']
  assert sorted([r['index'] for r in exclusions]) == [
      'exclusion1',
      'exclusion2',
  ]
  values = [(r['index'], r['values']['filter']) for r in exclusions]
  assert sorted(values) == [
    ('exclusion1', 'resource.type=gce_instance'),
    ('exclusion2', 'severity=NOTICE')
  ]
