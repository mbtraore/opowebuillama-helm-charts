{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "webui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "webui.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "webui.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "webui.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "webui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "webui.labels" -}}
helm.sh/chart: {{ include "webui.chart" . }}
{{ include "webui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: webui
{{- end }}

{{/*
Selector labels
*/}}
{{- define "webui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common deployment strategy definition
*/}}
{{- define "webui.strategy" -}}
{{- $preset := . -}}
{{- if (eq (toString $preset.type) "Recreate") }}
type: Recreate
{{- else if (eq (toString $preset.type) "RollingUpdate") }}
type: RollingUpdate
{{- with $preset.rollingUpdate }}
rollingUpdate:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Create a default fully qualified Ollama URL.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ollama.url" -}}
{{- if .Values.ollama.enabled }}
  {{- $serviceName := default .Chart.Name .Values.ollama.nameOverride -}}
  {{- $fullname := printf "http://%s-%s.%s.svc.cluster.local:%d/api" (.Release.Name) $serviceName (.Release.Namespace) (.Values.ollama.service.servicePortHttp | int) -}}
  {{- $truncated := trunc 63 $fullname -}}
  {{- $finalName := lower $truncated -}}
  {{ print $finalName -}}
{{- else -}}
  {{ print .Values.ollama.externalURL -}}
{{- end -}}
{{- end -}}

{{/*
Return OpenAI API Secret Name
*/}}
{{- define "openai.apiKeySecretName" -}}
{{- if .Values.openai.enabled }}
    {{- if .Values.openai.existingApiKeySecret -}}
    {{- print .Values.openai.existingApiKeySecret -}}
    {{- else -}}
    {{- printf "%s-%s" (include "webui.fullname" .) "openai-api-key" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return OpenAI API Secret key
*/}}
{{- define "openai.apiKeySecretKey" -}}
{{- if .Values.openai.enabled }}
    {{- if .Values.openai.existingApiKeySecretKey -}}
    {{- print .Values.openai.existingApiKeySecretKey -}}
    {{- else -}}
    {{- print "openai-api-key" -}}
    {{- end -}}
{{- end -}}
{{- end -}}
