{{- define "fullName" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "commonLabels" -}}
app.kubernetes.io/name: trilium
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "selectorLabels" -}}
app.kubernetes.io/name: trilium
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{- define "trilium.image" -}}
{{- include "trilium.image.name" (list . .Values.image) -}}
{{- end -}}

{{- define "trilium.image.name" -}}
{{- $root := index . 0 -}}
{{- $image := index . 1 -}}
{{- if $image.digest }}
  {{- printf "%s@%s" $image.repository $image.digest -}}
{{- else -}}
  {{- printf "%s:%s" $image.repository $image.tag -}}
{{- end -}}
{{- end -}}


