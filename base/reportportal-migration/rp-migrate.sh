#!/usr/bin/env bash

# strict fail on migration script
set -o pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

scriptfile=$(readlink -f $0)
scriptname=${scriptfile/*\//}

ocp_c1_request="https://oauth-openshift.apps.ocp-c1.prod.psi.redhat.com/oauth/token/request"
ocp_hub_request="https://oauth-dno-dno.apps.ocp-hub.prod.psi.redhat.com/oauth/token/request"

ocp_c1_server="https://api.ocp-c1.prod.psi.redhat.com:6443"
ocp_hub_server="https://api.dno.ocp-hub.prod.psi.redhat.com:6443"

if [ "$#" -le 0 ] || [ "$#" -gt 2 ]; then
  	echo >&2 "Usage is: ./$scriptname <ReportPortal Team>"
    echo >&2 "For example: ./$scriptname cnv"
	exit 1
fi

if [ "$#" -eq 2 ]; then
    if [[ "$2" == "" ]] || [[ -z "$2" ]]; then
        RP_STAGE="full"
    else
        RP_STAGE="$2"
    fi
fi

RP_SHORT_NAME="$1"
OLD_PROJECT_NAME="reportportal-${RP_SHORT_NAME}"
DESTINATION_PROJECT_NAME="dno--${OLD_PROJECT_NAME}"
BASE_YAML_LOCATION="live"
cd "$BASE_YAML_LOCATION"

if [[ ! -f "../base/rp-ops-v1.0/stc-maintenance.template.yaml" ]]; then
    echo "Are you in the right location? file not found"
    exit 1
fi

function wait_for_y() {
    while true; do
        read -p "Do you want to continue? (y to proceed): " input
        if [[ "$input" == "y" ]]; then
            break
        fi
    done
}

function get_logins() {
    echo >&2 "New step: saving ocp tokens.."
    echo >&2 "$ocp_c1_request"
    read -s -p "OCP token?: " ocp_c1_token

    echo >&2 "Thank you, another one.."
    echo >&2 "$ocp_hub_request"
    read -s -p "OCP token?: " ocp_hub_token
}

function ocp_login() {
    if ! command -v oc > /dev/null; then
    echo >&2 "Origin client 'oc' is not installed"
    exit 1
    fi

    ocp_instance="$1"
    project="$2"
    if [[ "$ocp_instance" == "ocp-c1" ]]; then
        OCPAPI="$ocp_c1_server"
    else
        OCPAPI="$ocp_hub_server"
    fi

    if [[ "$(oc project)" != *"${OCPAPI}"* ]] > /dev/null 2>&1; then
        if [[ "$ocp_instance" == "ocp-c1" ]]; then
            oc login --token "${ocp_c1_token}" -n "${project}" --server="${OCPAPI}"
        else
            oc login --token "${ocp_hub_token}" -n "${project}" --server="${OCPAPI}"
        fi
        if [ $? -ne 0 ]; then
            echo >&2 "can't login to ${OCPAPI} using the provided token"
            exit 1
        fi
    fi

    oc get project "${project}" > /dev/null 2>&1
    if [ "$?" != "0" ]; then
        echo ""
        echo "ERROR"
        echo "The project: '${project}' does not exist in ${OCPAPI}"
        exit 1
    fi
    oc project ${project}
    echo " "
}

function process_ocp_c1() {
    echo >&2 "### Creating maintenance pod at the old cluster..."
    echo >&2 "## deleting old..."
    oc delete job reportportal-maintenance-sleep -n ${OLD_PROJECT_NAME} --ignore-not-found=true
    oc delete pvc recovery -n ${OLD_PROJECT_NAME} --wait=false --ignore-not-found=true > /dev/null 2>&1
    remove_pvc_protection "${OLD_PROJECT_NAME}"
    oc delete cm reportportal-utils -n ${OLD_PROJECT_NAME} --ignore-not-found=true
    echo >&2 "## creating new..."
    oc process -f ../base/rp-ops-v1.0/stc-maintenance.template.yaml -p INSTANCE=${RP_SHORT_NAME} RECOVERY_SIZE=400Gi STORAGECLASS=dynamic-nfs | oc create -f - -n ${OLD_PROJECT_NAME} > /dev/null 2>&1
    sleep 10

    # catches random new line, need to debug
    echo "press Enter if prompt is running for more than 10sec"
    read -s -p "enter_honey_pot: " test_var
    echo "${test_var}"
}

function process_ocp_hub() {
    echo >&2 "### Creating maintenance pod at the destination cluster..."
    echo >&2 "## deleting old..."
    oc delete job reportportal-maintenance-sleep -n ${DESTINATION_PROJECT_NAME} --ignore-not-found=true
    oc delete pvc recovery -n ${DESTINATION_PROJECT_NAME} --wait=false --ignore-not-found=true > /dev/null 2>&1
    remove_pvc_protection "${DESTINATION_PROJECT_NAME}"
    oc delete cm reportportal-utils -n ${DESTINATION_PROJECT_NAME} --ignore-not-found=true
    echo >&2 "## creating new..."
    oc process -f ../base/rp-ops-v1.0/stc-maintenance.template.yaml -p INSTANCE=${RP_SHORT_NAME} RECOVERY_SIZE=400Gi | oc create -f - -n ${DESTINATION_PROJECT_NAME} > /dev/null 2>&1
    wait_for_pod

    echo >&2 "## scaling down api + uat..."
    oc scale deploy ${OLD_PROJECT_NAME}-api ${OLD_PROJECT_NAME}-uat --replicas=0 -n "${DESTINATION_PROJECT_NAME}"

    echo >&2 "## increasing project pod/container limits..."
    set_project_limits

    echo >&2 "## running migration pipeline..."
    oc process -f ../base/rp-ops-v1.0/rp-migrate-pipelinerun.template.yaml | oc create -f - -n ${DESTINATION_PROJECT_NAME}
    sleep 5
}

function get_migration_pipeline_info() {
    pipelinerun_name=$(tkn pipelinerun list -n "${DESTINATION_PROJECT_NAME}" | grep rp-migrate | head -n 1 | cut -d' ' -f1)
    tkn pipelinerun logs "${pipelinerun_name}" --last -f -n "${DESTINATION_PROJECT_NAME}"
    pipelinerun_status=$(tkn pipelinerun describe "${pipelinerun_name}" -n "${DESTINATION_PROJECT_NAME}" -o json | jq -r '.status.conditions[0].reason' || true)
    
    if [[ "$pipelinerun_status" != "Succeeded" ]]; then
        echo >&2 "==============================="
        echo >&2 "OpenShift pipeline status is: ${pipelinerun_status}"
        echo >&2 "==============================="
        echo >&2 "You could also browse the progress using this link:"
        echo >&2 "https://console-openshift-console.apps.dno.ocp-hub.prod.psi.redhat.com/k8s/ns/${DESTINATION_PROJECT_NAME}/tekton.dev~v1~Pipeline/rp-migrate/Runs/"

        echo -e >&2 "It seems like the process have failed? Plese continue in case it's Succeeded"
        wait_for_y
    fi
}

function update_schema_and_scale_up() {
    echo >&2 "## updating database schemas..."
    oc process -f ../base/rp-ops-v1.0/rp-migrations-job.template.yaml -p INSTANCE=${RP_SHORT_NAME} | oc delete -f - -n "${DESTINATION_PROJECT_NAME}" --ignore-not-found=true
    oc process -f ../base/rp-ops-v1.0/rp-migrations-job.template.yaml -p INSTANCE=${RP_SHORT_NAME} | oc create -f - -n "${DESTINATION_PROJECT_NAME}"
    sleep 15

    oc scale deploy --all --replicas=1 -n "${DESTINATION_PROJECT_NAME}"
    wait_for_deployment "${OLD_PROJECT_NAME}-api" "${DESTINATION_PROJECT_NAME}"
    wait_for_deployment "${OLD_PROJECT_NAME}-uat" "${DESTINATION_PROJECT_NAME}"
    echo >&2 "Check UI using this link:"
    echo >&2 "https://reportportal-${RP_SHORT_NAME}.apps.dno.ocp-hub.prod.psi.redhat.com/ui/"
}

function set_project_limits() {
    oc get limitrange limits -n "${DESTINATION_PROJECT_NAME}" -o json \
        | jq '(.spec.limits[] | select(.type == "Pod") | .max.cpu) = "6" | 
                (.spec.limits[] | select(.type == "Pod") | .max.memory) = "16Gi" | 
                (.spec.limits[] | select(.type == "Container") | .max.cpu) = "6" | 
                (.spec.limits[] | select(.type == "Container") | .max.memory) = "16Gi"' \
        | oc apply -f - -n "${DESTINATION_PROJECT_NAME}"
}

function delete_temp_resources_ocp_hub() {
    echo >&2 "### Deleting temp resources..."
    echo >&2 "Please continue only in case you could login to UI"
    wait_for_y

    echo >&2 "## deleting temp resources in ocp-hub..."
    oc delete job reportportal-maintenance-sleep -n ${DESTINATION_PROJECT_NAME} --ignore-not-found=true
    oc delete pvc recovery -n ${DESTINATION_PROJECT_NAME} --wait=false --ignore-not-found=true > /dev/null 2>&1
    remove_pvc_protection "${DESTINATION_PROJECT_NAME}"
    oc delete cm reportportal-utils -n ${DESTINATION_PROJECT_NAME} --ignore-not-found=true
}

function delete_temp_resources_ocp_c1() {
    echo >&2 "## deleting temp resources in ocp-c1..."
    oc delete job reportportal-maintenance-sleep -n "${OLD_PROJECT_NAME}" --ignore-not-found=true
    oc delete pvc recovery -n "${OLD_PROJECT_NAME}" --wait=false --ignore-not-found=true > /dev/null 2>&1
    remove_pvc_protection "${OLD_PROJECT_NAME}"
    oc delete cm reportportal-utils -n "${OLD_PROJECT_NAME}" --ignore-not-found=true
}

function set_label_ocp_c1() {
    echo >&2 "## setting label in ocp-c1..."
    deployment_to_label="reportportal-api"
    oc label deployment "${deployment_to_label}" -n "${OLD_PROJECT_NAME}" ocp-hub-migration=migrated --overwrite
}

function message_end_migration() {
    echo -e >&2 "### Migration of ${OLD_PROJECT_NAME} is finished! \xE2\x9C\x94"
}

function remove_pvc_protection() {
    namespace="$1"
    echo -e >&2 "# removing finalizers (pvc-protection)"
    oc patch pvc recovery -n "${namespace}" --type='merge' -p '{"metadata":{"finalizers":null}}'
}

function wait_for_pod() {
    echo -e >&2 "### waiting for pod to be ready, sleeping 30sec"
    sleep 30
}

function wait_for_deployment() {
    DEPLOYMENT="$1"
    NAMESPACE="$2"

    echo "Waiting for deployment $DEPLOYMENT to be fully available..."

    while true; do
        READY_REPLICAS=$(oc get deployment "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}')
        TOTAL_REPLICAS=$(oc get deployment "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')

        if [[ "$READY_REPLICAS" == "$TOTAL_REPLICAS" && -n "$READY_REPLICAS" ]]; then
            echo "Deployment $DEPLOYMENT is fully available with $READY_REPLICAS/$TOTAL_REPLICAS replicas."
            break
        fi

        echo "Deployment $DEPLOYMENT is not fully available yet ($READY_REPLICAS/$TOTAL_REPLICAS). Retrying in 5s..."
        sleep 5
    done
}

main() {
    get_logins
    if [[ "$RP_STAGE" != "post" ]]; then
        ocp_login "ocp-c1" "$OLD_PROJECT_NAME"
        process_ocp_c1
        ocp_login "ocp-hub" "$DESTINATION_PROJECT_NAME"
        process_ocp_hub
    else
        ocp_login "ocp-hub" "$DESTINATION_PROJECT_NAME"
    fi
    get_migration_pipeline_info
    update_schema_and_scale_up

    delete_temp_resources_ocp_hub
    ocp_login "ocp-c1" "$OLD_PROJECT_NAME"
    delete_temp_resources_ocp_c1
    set_label_ocp_c1
    message_end_migration
}
main "$@"
